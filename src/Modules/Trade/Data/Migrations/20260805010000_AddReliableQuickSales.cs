using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Trade.Data.Migrations;

[DbContext(typeof(TradeDbContext))]
[Migration("20260805010000_AddReliableQuickSales")]
public sealed class AddReliableQuickSales : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(name: "outbox_messages", schema: "trade", columns: table => new
        {
            Id = table.Column<Guid>(type: "uuid", nullable: false), MessageId = table.Column<Guid>(type: "uuid", nullable: false),
            CorrelationId = table.Column<Guid>(type: "uuid", nullable: false), EventType = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
            Payload = table.Column<string>(type: "jsonb", nullable: false), OccurredAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
            ProcessedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true), RetryCount = table.Column<int>(type: "integer", nullable: false),
            NextAttemptAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true), LastError = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: true)
        }, constraints: table => table.PrimaryKey("PK_outbox_messages", x => x.Id));
        migrationBuilder.CreateTable(name: "processed_messages", schema: "trade", columns: table => new
        {
            Id = table.Column<Guid>(type: "uuid", nullable: false), MessageId = table.Column<Guid>(type: "uuid", nullable: false),
            ConsumerName = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: false),
            ProcessedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
        }, constraints: table => table.PrimaryKey("PK_processed_messages", x => x.Id));
        migrationBuilder.CreateTable(name: "quick_sales", schema: "trade", columns: table => new
        {
            Id = table.Column<Guid>(type: "uuid", nullable: false), TenantId = table.Column<Guid>(type: "uuid", nullable: false), BranchId = table.Column<Guid>(type: "uuid", nullable: false),
            CreatedByUserId = table.Column<Guid>(type: "uuid", nullable: false), SaleNumber = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
            IdempotencyKey = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false), Status = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
            PaymentMethod = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false), Subtotal = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
            DiscountAmount = table.Column<decimal>(type: "numeric(18,2)", nullable: false), TotalAmount = table.Column<decimal>(type: "numeric(18,2)", nullable: false), PaidAmount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
            AccountingInvoiceId = table.Column<Guid>(type: "uuid", nullable: true), AccountingPaymentId = table.Column<Guid>(type: "uuid", nullable: true), FailureReason = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
            CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false), CompletedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true),
            FailedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true), UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
        }, constraints: table => table.PrimaryKey("PK_quick_sales", x => x.Id));
        migrationBuilder.CreateTable(name: "quick_sale_items", schema: "trade", columns: table => new
        {
            Id = table.Column<Guid>(type: "uuid", nullable: false), QuickSaleId = table.Column<Guid>(type: "uuid", nullable: false), StockItemId = table.Column<Guid>(type: "uuid", nullable: false),
            ProductNameSnapshot = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false), SkuSnapshot = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
            BarcodeSnapshot = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: true), Quantity = table.Column<long>(type: "bigint", nullable: false),
            UnitPriceSnapshot = table.Column<decimal>(type: "numeric(18,2)", nullable: false), LineTotal = table.Column<decimal>(type: "numeric(18,2)", nullable: false)
        }, constraints: table =>
        {
            table.PrimaryKey("PK_quick_sale_items", x => x.Id);
            table.ForeignKey(name: "FK_quick_sale_items_quick_sales_QuickSaleId", column: x => x.QuickSaleId,
                principalSchema: "trade", principalTable: "quick_sales", principalColumn: "Id", onDelete: ReferentialAction.Cascade);
        });

        migrationBuilder.CreateIndex(name: "IX_outbox_messages_MessageId", schema: "trade", table: "outbox_messages", column: "MessageId", unique: true);
        migrationBuilder.CreateIndex(name: "IX_outbox_messages_ProcessedAtUtc_NextAttemptAtUtc", schema: "trade", table: "outbox_messages", columns: new[] { "ProcessedAtUtc", "NextAttemptAtUtc" });
        migrationBuilder.CreateIndex(name: "IX_processed_messages_ConsumerName_MessageId", schema: "trade", table: "processed_messages", columns: new[] { "ConsumerName", "MessageId" }, unique: true);
        migrationBuilder.CreateIndex(name: "IX_quick_sales_TenantId_IdempotencyKey", schema: "trade", table: "quick_sales", columns: new[] { "TenantId", "IdempotencyKey" }, unique: true);
        migrationBuilder.CreateIndex(name: "IX_quick_sales_TenantId_SaleNumber", schema: "trade", table: "quick_sales", columns: new[] { "TenantId", "SaleNumber" }, unique: true);
        migrationBuilder.CreateIndex(name: "IX_quick_sales_TenantId_BranchId_CreatedAtUtc", schema: "trade", table: "quick_sales", columns: new[] { "TenantId", "BranchId", "CreatedAtUtc" });
        migrationBuilder.CreateIndex(name: "IX_quick_sale_items_QuickSaleId_StockItemId", schema: "trade", table: "quick_sale_items", columns: new[] { "QuickSaleId", "StockItemId" }, unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable("quick_sale_items", "trade"); migrationBuilder.DropTable("quick_sales", "trade");
        migrationBuilder.DropTable("outbox_messages", "trade"); migrationBuilder.DropTable("processed_messages", "trade");
    }
}
