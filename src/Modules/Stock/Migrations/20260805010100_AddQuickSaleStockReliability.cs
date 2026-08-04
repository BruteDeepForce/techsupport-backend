using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using TechSupport.Stock.Data;

#nullable disable
namespace TechSupport.Stock.Migrations;

[DbContext(typeof(StockDbContext))]
[Migration("20260805010100_AddQuickSaleStockReliability")]
public sealed class AddQuickSaleStockReliability : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<Guid>(name: "ReferenceId", schema: "stock", table: "stock_transactions", type: "uuid", nullable: true);
        migrationBuilder.AddColumn<string>(name: "ReferenceType", schema: "stock", table: "stock_transactions", type: "character varying(64)", maxLength: 64, nullable: true);
        migrationBuilder.AddColumn<string>(name: "IdempotencyKey", schema: "stock", table: "stock_transactions", type: "character varying(256)", maxLength: 256, nullable: true);
        migrationBuilder.CreateIndex(name: "IX_stock_transactions_TenantId_ReferenceType_ReferenceId_StockItemId_Type", schema: "stock", table: "stock_transactions", columns: new[] { "TenantId", "ReferenceType", "ReferenceId", "StockItemId", "Type" }, unique: true);
        CreateIntegrationTables(migrationBuilder);
    }
    private static void CreateIntegrationTables(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(name: "outbox_messages", schema: "stock", columns: table => new { Id = table.Column<Guid>("uuid", nullable: false), MessageId = table.Column<Guid>("uuid", nullable: false), CorrelationId = table.Column<Guid>("uuid", nullable: false), EventType = table.Column<string>("character varying(1000)", maxLength: 1000, nullable: false), Payload = table.Column<string>("jsonb", nullable: false), OccurredAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: false), ProcessedAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: true), RetryCount = table.Column<int>("integer", nullable: false), NextAttemptAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: true), LastError = table.Column<string>("character varying(4000)", maxLength: 4000, nullable: true) }, constraints: table => table.PrimaryKey("PK_outbox_messages", x => x.Id));
        migrationBuilder.CreateTable(name: "processed_messages", schema: "stock", columns: table => new { Id = table.Column<Guid>("uuid", nullable: false), MessageId = table.Column<Guid>("uuid", nullable: false), ConsumerName = table.Column<string>("character varying(300)", maxLength: 300, nullable: false), ProcessedAtUtc = table.Column<DateTimeOffset>("timestamp with time zone", nullable: false) }, constraints: table => table.PrimaryKey("PK_processed_messages", x => x.Id));
        migrationBuilder.CreateIndex(name: "IX_outbox_messages_MessageId", schema: "stock", table: "outbox_messages", column: "MessageId", unique: true);
        migrationBuilder.CreateIndex(name: "IX_outbox_messages_ProcessedAtUtc_NextAttemptAtUtc", schema: "stock", table: "outbox_messages", columns: new[] { "ProcessedAtUtc", "NextAttemptAtUtc" });
        migrationBuilder.CreateIndex(name: "IX_processed_messages_ConsumerName_MessageId", schema: "stock", table: "processed_messages", columns: new[] { "ConsumerName", "MessageId" }, unique: true);
    }
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable("outbox_messages", "stock"); migrationBuilder.DropTable("processed_messages", "stock");
        migrationBuilder.DropIndex(name: "IX_stock_transactions_TenantId_ReferenceType_ReferenceId_StockItemId_Type", schema: "stock", table: "stock_transactions");
        migrationBuilder.DropColumn(name: "ReferenceId", schema: "stock", table: "stock_transactions"); migrationBuilder.DropColumn(name: "ReferenceType", schema: "stock", table: "stock_transactions"); migrationBuilder.DropColumn(name: "IdempotencyKey", schema: "stock", table: "stock_transactions");
    }
}
