using System.Text;
using System.Text.RegularExpressions;

namespace TechSupport.Ai.Services.PolicyDocuments;

public class PolicyChunkingService : IPolicyChunkingService
{
    private static readonly Regex PageRegex = new("^\\[Page\\s+(\\d+)\\]$", RegexOptions.Compiled | RegexOptions.IgnoreCase);

    private static readonly Regex SectionHeaderRegex = new(
        "^(?:\\d+(?:[.)]\\d+)*[.)]?\\s+.+|(?:Madde|Bölüm|Bolum|Ek|Section|Article)\\s*[:\\-]?\\s+.+)$",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    public IReadOnlyList<PolicyChunk> CreateChunks(string extractedText, PolicyChunkingOptions? options = null)
    {
        options ??= new PolicyChunkingOptions();

        if (string.IsNullOrWhiteSpace(extractedText))
            return Array.Empty<PolicyChunk>();

        var sectionBlocks = ParseSectionBlocks(extractedText);
        var chunks = new List<PolicyChunk>();
        var index = 0;

        foreach (var block in sectionBlocks)
        {
            var blockChunks = ChunkSectionBlock(block, options, index);
            chunks.AddRange(blockChunks);
            index += blockChunks.Count;
        }

        return MergeTooSmallTailChunks(chunks, options.MinTokens);
    }

    private static List<SectionBlock> ParseSectionBlocks(string text)
    {
        var blocks = new List<SectionBlock>();

        var lines = text.Replace("\r", "\n").Split('\n');
        var currentSection = "Genel";
        int? currentPage = null;
        int? blockStartPage = null;
        var buffer = new StringBuilder();

        void Flush()
        {
            var content = buffer.ToString().Trim();
            if (string.IsNullOrWhiteSpace(content))
            {
                buffer.Clear();
                return;
            }

            blocks.Add(new SectionBlock(
                currentSection,
                blockStartPage,
                currentPage,
                content));

            buffer.Clear();
        }

        foreach (var rawLine in lines)
        {
            var line = rawLine.Trim();
            if (line.Length == 0)
            {
                if (buffer.Length > 0)
                    buffer.AppendLine();

                continue;
            }

            var pageMatch = PageRegex.Match(line);
            if (pageMatch.Success)
            {
                if (int.TryParse(pageMatch.Groups[1].Value, out var page))
                {
                    currentPage = page;
                    if (blockStartPage is null)
                        blockStartPage = page;
                }

                continue;
            }

            if (IsSectionHeader(line))
            {
                Flush();
                currentSection = line;
                blockStartPage = currentPage;
                continue;
            }

            if (buffer.Length > 0)
                buffer.AppendLine();

            buffer.Append(line);
        }

        Flush();
        return blocks;
    }

    private static List<PolicyChunk> ChunkSectionBlock(SectionBlock block, PolicyChunkingOptions options, int startIndex)
    {
        var chunks = new List<PolicyChunk>();
        var sentences = SplitIntoSentences(block.Text);

        if (sentences.Count == 0)
            return chunks;

        var cursor = 0;
        var chunkIndex = startIndex;
        var overlapSeed = string.Empty;

        while (cursor < sentences.Count)
        {
            var currentSentences = new List<string>();
            var tokenCount = 0;

            if (!string.IsNullOrWhiteSpace(overlapSeed))
            {
                currentSentences.Add(overlapSeed);
                tokenCount += EstimateTokens(overlapSeed);
            }

            while (cursor < sentences.Count)
            {
                var sentence = sentences[cursor];
                var sentenceTokens = EstimateTokens(sentence);

                if (currentSentences.Count > 0 && tokenCount + sentenceTokens > options.MaxTokens)
                    break;

                currentSentences.Add(sentence);
                tokenCount += sentenceTokens;
                cursor++;

                if (tokenCount >= options.TargetTokens)
                    break;
            }

            if (currentSentences.Count == 0 && cursor < sentences.Count)
            {
                var sentence = sentences[cursor];
                currentSentences.Add(sentence);
                tokenCount = EstimateTokens(sentence);
                cursor++;
            }

            var text = string.Join(' ', currentSentences).Trim();
            if (text.Length == 0)
                continue;

            chunks.Add(new PolicyChunk(
                ChunkIndex: chunkIndex++,
                SectionTitle: block.SectionTitle,
                PageStart: block.PageStart,
                PageEnd: block.PageEnd,
                ApproxTokenCount: tokenCount,
                Text: text));

            overlapSeed = BuildOverlapSeed(currentSentences, options.OverlapTokens);
        }

        return chunks;
    }

    private static string BuildOverlapSeed(IReadOnlyList<string> sentences, int overlapTokens)
    {
        if (sentences.Count == 0 || overlapTokens <= 0)
            return string.Empty;

        var selected = new List<string>();
        var acc = 0;

        for (var i = sentences.Count - 1; i >= 0; i--)
        {
            var s = sentences[i];
            var t = EstimateTokens(s);

            if (selected.Count > 0 && acc + t > overlapTokens)
                break;

            selected.Add(s);
            acc += t;
        }

        selected.Reverse();
        return string.Join(' ', selected).Trim();
    }

    private static IReadOnlyList<PolicyChunk> MergeTooSmallTailChunks(IReadOnlyList<PolicyChunk> chunks, int minTokens)
    {
        if (chunks.Count <= 1 || minTokens <= 0)
            return chunks;

        var result = new List<PolicyChunk>();

        foreach (var chunk in chunks)
        {
            if (result.Count == 0)
            {
                result.Add(chunk);
                continue;
            }

            var prev = result[^1];
            if (chunk.ApproxTokenCount >= minTokens)
            {
                result.Add(chunk);
                continue;
            }

            var mergedText = $"{prev.Text} {chunk.Text}".Trim();
            var mergedTokens = prev.ApproxTokenCount + chunk.ApproxTokenCount;

            result[^1] = prev with
            {
                Text = mergedText,
                ApproxTokenCount = mergedTokens,
                PageEnd = chunk.PageEnd ?? prev.PageEnd
            };
        }

        for (var i = 0; i < result.Count; i++)
            result[i] = result[i] with { ChunkIndex = i };

        return result;
    }

    private static bool IsSectionHeader(string line)
    {
        if (line.Length < 3 || line.Length > 180)
            return false;

        return SectionHeaderRegex.IsMatch(line);
    }

    private static List<string> SplitIntoSentences(string input)
    {
        var normalized = Regex.Replace(input, "\\s+", " ").Trim();
        if (normalized.Length == 0)
            return new List<string>();

        var parts = Regex.Split(normalized, @"(?<=[\\.\\!\\?;:])\\s+")
            .Select(x => x.Trim())
            .Where(x => x.Length > 0)
            .ToList();

        return parts.Count == 0 ? new List<string> { normalized } : parts;
    }

    private static int EstimateTokens(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return 0;

        // Lightweight approximation: Turkish/English mixed policy text
        // tends to be around 1.2-1.5 tokens per word.
        var words = Regex.Matches(text, "\\S+").Count;
        return Math.Max(1, (int)Math.Ceiling(words * 1.35));
    }

    private sealed record SectionBlock(
        string SectionTitle,
        int? PageStart,
        int? PageEnd,
        string Text);
}
