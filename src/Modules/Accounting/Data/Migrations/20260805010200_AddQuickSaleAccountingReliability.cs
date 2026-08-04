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
        migrationBuilder.CreateTable(name: "inbox_messages", schema: "accounting", columns: table => new
        {
            Id = table.Column<Guid>("uuid", nullable: false),
            MessageId = table.Column<Guid>("uuid", nullable: false),
            ConsumerName = table.Column<string>("character varying(300)", maxLength: 300, nullable: false),
            ResponseType = table.Column<string>("character varying(1000)", maxLength: 1000, nullable: false),
            ResponsePayload = table.Column<string>("jsonb", nullable: false),
            ProcessedAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: false)
        }, constraints: table => table.PrimaryKey("PK_inbox_messages", x => x.Id));
        migrationBuilder.CreateIndex(name: "IX_inbox_messages_ConsumerName_MessageId", schema: "accounting", table: "inbox_messages", columns: new[] { "ConsumerName", "MessageId" }, unique: true);
        migrationBuilder.CreateIndex(name: "IX_cari_hesap_hareketleri_TenantId_ReferansNumarasi", schema: "accounting", table: "cari_hesap_hareketleri", columns: new[] { "TenantId", "ReferansNumarasi" }, unique: true, filter: "\"ReferansNumarasi\" IS NOT NULL");
    }
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable("inbox_messages", "accounting");
        migrationBuilder.DropIndex(name: "IX_cari_hesap_hareketleri_TenantId_ReferansNumarasi", schema: "accounting", table: "cari_hesap_hareketleri");
    }
}
