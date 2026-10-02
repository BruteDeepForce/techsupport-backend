using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Amazon;
using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;

namespace TechSupport.Ai.Services.SemanticKernel.S3
{
    public class S3Service
    {
        private readonly IAmazonS3 _s3Client;
        private readonly IConfiguration _configuration;
        public S3Service(IConfiguration configuration)
        {
            _configuration = configuration;
            var accessKey = _configuration["AWS:AccessKey"];
            var secretKey = _configuration["AWS:SecretKey"];
            var region = _configuration["AWS:Region"] ?? "us-east-1";
            _s3Client = new AmazonS3Client(accessKey, secretKey, RegionEndpoint.GetBySystemName(region));
        }

        public async Task<string> UploadPdfFileAsync(IFormFile file, string key, CancellationToken ct)
        {
            var bucketName = _configuration["AWS:S3BucketName"];
            using var fileStream = file.OpenReadStream();

            var s3Key = $"lineer-ai-pdf/{key}";

            var putRequest = new PutObjectRequest
            {
                BucketName = bucketName,
                Key = s3Key,
                InputStream = fileStream,
                ContentType = "application/pdf"
            };

            var response = await _s3Client.PutObjectAsync(putRequest, ct);
            if (response.HttpStatusCode == System.Net.HttpStatusCode.OK)
            {
                return $"https://{bucketName}.s3.amazonaws.com/{s3Key}";
            }
            else
            {
                throw new Exception("Failed to upload file to S3");
            }
        }

        public async Task<IReadOnlyCollection<PolicyDocument>> GetDocumentsFromS3Async(Guid tenantId, CancellationToken cancellationToken)
        {
            var bucketName = _configuration["AWS:S3BucketName"];

            var result = await _s3Client.ListObjectsV2Async(new ListObjectsV2Request
            {
                BucketName = bucketName,
                Prefix = $"lineer-ai-pdf/policy/{tenantId}"
            }, cancellationToken);

            var documents = result.S3Objects.Select(o =>
            {
                var urlRequest = new GetPreSignedUrlRequest
                {
                    BucketName = bucketName,
                    Key = o.Key,
                    Expires = DateTime.UtcNow.AddMinutes(15)
                };

                return new PolicyDocument(
                    Title: Path.GetFileNameWithoutExtension(o.Key).Split('_').LastOrDefault(),
                    Key: o.Key,
                    Url: _s3Client.GetPreSignedURL(urlRequest)
                );
            }).ToList();

            if (documents.Count == 0)
            {
                throw new Exception("No documents found in S3");
            }

            return documents;
        }

        public sealed record PolicyDocument(string? Title, string Key, string Url);
    }
}