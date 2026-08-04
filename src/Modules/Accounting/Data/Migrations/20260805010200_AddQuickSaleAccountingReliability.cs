using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable
namespace TechSupport.Accounting.Data.Migrations;

[DbContext(typeof(AccountingDbContext))]
[Migration("20260805010200_AddQuickSaleAccountingReliability")]
public sealed class AddQuickSaleAccountingReliability : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(name: "outbox_messages", schema: "accounting", columns: table => new { Id = table.Column<Guid>("uuid", nullable: false), MessageId = table.Column<Guid>("uuid", nullable: false), CorrelationId = table.Column<Guid>("uuid", nullable: false), EventType = table.Column<string>("character varying(1000)", maxLength: 1000, nullable: false), Payload = table.Column<string>("jsonb", nullable: false), OccurredAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: false), ProcessedAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: true), RetryCount = table.Column<int>("integer", nullable: false), NextAttemptAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: true), LastError = table.Column<string>("character varying(4000)", maxLength: 4000, nullable: true) }, constraints: table => table.PrimaryKey("PK_outbox_messages", x => x.Id));
        migrationBuilder.CreateTable(name: "processed_messages", schema: "accounting", columns: table => new { Id = table.Column<Guid>("uuid", nullable: false), MessageId = table.Column<Guid>("uuid", nullable: false), ConsumerName = table.Column<string>("character varying(300)", maxLength: 300, nullable: false), ProcessedAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: false) }, constraints: table => table.PrimaryKey("PK_processed_messages", x => x.Id));
        migrationBuilder.CreateIndex(name: "IX_outbox_messages_MessageId", schema: "accounting", table: "outbox_messages", column: "MessageId", unique: true);
        migrationBuilder.CreateIndex(name: "IX_outbox_messages_ProcessedAtUtc_NextAttemptAtUtc", schema: "accounting", table: "outbox_messages", columns: new[] { "ProcessedAtUtc", "NextAttemptAtUtc" });
        migrationBuilder.CreateIndex(name: "IX_processed_messages_ConsumerName_MessageId", schema: "accounting", table: "processed_messages", columns: new[] { "ConsumerName", "MessageId" }, unique: true);
        migrationBuilder.CreateIndex(name: "IX_cari_hesap_hareketleri_TenantId_ReferansNumarasi", schema: "accounting", table: "cari_hesap_hareketleri", columns: new[] { "TenantId", "ReferansNumarasi" }, unique: true, filter: "\"ReferansNumarasi\" IS NOT NULL");
    }
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable("outbox_messages", "accounting"); migrationBuilder.DropTable("processed_messages", "accounting");
        migrationBuilder.DropIndex(name: "IX_cari_hesap_hareketleri_TenantId_ReferansNumarasi", schema: "accounting", table: "cari_hesap_hareketleri");
    }
}
