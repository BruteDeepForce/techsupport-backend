using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class SetStockTableNamesAndSchema : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_StockBalances_StockItems_StockItemId",
                table: "StockBalances");

            migrationBuilder.DropForeignKey(
                name: "FK_StockReservations_StockItems_StockItemId",
                table: "StockReservations");

            migrationBuilder.DropForeignKey(
                name: "FK_StockTransactions_StockItems_StockItemId",
                table: "StockTransactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StockTransactions",
                table: "StockTransactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StockReservations",
                table: "StockReservations");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StockItems",
                table: "StockItems");

            migrationBuilder.DropPrimaryKey(
                name: "PK_StockBalances",
                table: "StockBalances");

            migrationBuilder.EnsureSchema(
                name: "stock");

            migrationBuilder.RenameTable(
                name: "StockTransactions",
                newName: "stock_transactions",
                newSchema: "stock");

            migrationBuilder.RenameTable(
                name: "StockReservations",
                newName: "stock_reservations",
                newSchema: "stock");

            migrationBuilder.RenameTable(
                name: "StockItems",
                newName: "stock_items",
                newSchema: "stock");

            migrationBuilder.RenameTable(
                name: "StockBalances",
                newName: "stock_balances",
                newSchema: "stock");

            migrationBuilder.RenameIndex(
                name: "IX_StockTransactions_TenantId_StockItemId",
                schema: "stock",
                table: "stock_transactions",
                newName: "IX_stock_transactions_TenantId_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_StockTransactions_StockItemId",
                schema: "stock",
                table: "stock_transactions",
                newName: "IX_stock_transactions_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_StockReservations_TenantId_OperationId",
                schema: "stock",
                table: "stock_reservations",
                newName: "IX_stock_reservations_TenantId_OperationId");

            migrationBuilder.RenameIndex(
                name: "IX_StockReservations_StockItemId",
                schema: "stock",
                table: "stock_reservations",
                newName: "IX_stock_reservations_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_StockItems_TenantId_Sku",
                schema: "stock",
                table: "stock_items",
                newName: "IX_stock_items_TenantId_Sku");

            migrationBuilder.RenameIndex(
                name: "IX_StockItems_TenantId_Barcode",
                schema: "stock",
                table: "stock_items",
                newName: "IX_stock_items_TenantId_Barcode");

            migrationBuilder.RenameIndex(
                name: "IX_StockBalances_TenantId_StockItemId_BranchId",
                schema: "stock",
                table: "stock_balances",
                newName: "IX_stock_balances_TenantId_StockItemId_BranchId");

            migrationBuilder.RenameIndex(
                name: "IX_StockBalances_StockItemId",
                schema: "stock",
                table: "stock_balances",
                newName: "IX_stock_balances_StockItemId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_stock_transactions",
                schema: "stock",
                table: "stock_transactions",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_stock_reservations",
                schema: "stock",
                table: "stock_reservations",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_stock_items",
                schema: "stock",
                table: "stock_items",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_stock_balances",
                schema: "stock",
                table: "stock_balances",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_stock_balances_stock_items_StockItemId",
                schema: "stock",
                table: "stock_balances",
                column: "StockItemId",
                principalSchema: "stock",
                principalTable: "stock_items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_stock_reservations_stock_items_StockItemId",
                schema: "stock",
                table: "stock_reservations",
                column: "StockItemId",
                principalSchema: "stock",
                principalTable: "stock_items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_stock_transactions_stock_items_StockItemId",
                schema: "stock",
                table: "stock_transactions",
                column: "StockItemId",
                principalSchema: "stock",
                principalTable: "stock_items",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_stock_balances_stock_items_StockItemId",
                schema: "stock",
                table: "stock_balances");

            migrationBuilder.DropForeignKey(
                name: "FK_stock_reservations_stock_items_StockItemId",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropForeignKey(
                name: "FK_stock_transactions_stock_items_StockItemId",
                schema: "stock",
                table: "stock_transactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_stock_transactions",
                schema: "stock",
                table: "stock_transactions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_stock_reservations",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropPrimaryKey(
                name: "PK_stock_items",
                schema: "stock",
                table: "stock_items");

            migrationBuilder.DropPrimaryKey(
                name: "PK_stock_balances",
                schema: "stock",
                table: "stock_balances");

            migrationBuilder.RenameTable(
                name: "stock_transactions",
                schema: "stock",
                newName: "StockTransactions");

            migrationBuilder.RenameTable(
                name: "stock_reservations",
                schema: "stock",
                newName: "StockReservations");

            migrationBuilder.RenameTable(
                name: "stock_items",
                schema: "stock",
                newName: "StockItems");

            migrationBuilder.RenameTable(
                name: "stock_balances",
                schema: "stock",
                newName: "StockBalances");

            migrationBuilder.RenameIndex(
                name: "IX_stock_transactions_TenantId_StockItemId",
                table: "StockTransactions",
                newName: "IX_StockTransactions_TenantId_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_stock_transactions_StockItemId",
                table: "StockTransactions",
                newName: "IX_StockTransactions_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_stock_reservations_TenantId_OperationId",
                table: "StockReservations",
                newName: "IX_StockReservations_TenantId_OperationId");

            migrationBuilder.RenameIndex(
                name: "IX_stock_reservations_StockItemId",
                table: "StockReservations",
                newName: "IX_StockReservations_StockItemId");

            migrationBuilder.RenameIndex(
                name: "IX_stock_items_TenantId_Sku",
                table: "StockItems",
                newName: "IX_StockItems_TenantId_Sku");

            migrationBuilder.RenameIndex(
                name: "IX_stock_items_TenantId_Barcode",
                table: "StockItems",
                newName: "IX_StockItems_TenantId_Barcode");

            migrationBuilder.RenameIndex(
                name: "IX_stock_balances_TenantId_StockItemId_BranchId",
                table: "StockBalances",
                newName: "IX_StockBalances_TenantId_StockItemId_BranchId");

            migrationBuilder.RenameIndex(
                name: "IX_stock_balances_StockItemId",
                table: "StockBalances",
                newName: "IX_StockBalances_StockItemId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StockTransactions",
                table: "StockTransactions",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StockReservations",
                table: "StockReservations",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StockItems",
                table: "StockItems",
                column: "Id");

            migrationBuilder.AddPrimaryKey(
                name: "PK_StockBalances",
                table: "StockBalances",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_StockBalances_StockItems_StockItemId",
                table: "StockBalances",
                column: "StockItemId",
                principalTable: "StockItems",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_StockReservations_StockItems_StockItemId",
                table: "StockReservations",
                column: "StockItemId",
                principalTable: "StockItems",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_StockTransactions_StockItems_StockItemId",
                table: "StockTransactions",
                column: "StockItemId",
                principalTable: "StockItems",
                principalColumn: "Id");
        }
    }
}
