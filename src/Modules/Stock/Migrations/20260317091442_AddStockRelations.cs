using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class AddStockRelations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_StockTransactions_StockItemId",
                table: "StockTransactions",
                column: "StockItemId");

            migrationBuilder.CreateIndex(
                name: "IX_StockReservations_StockItemId",
                table: "StockReservations",
                column: "StockItemId");

            migrationBuilder.CreateIndex(
                name: "IX_StockBalances_StockItemId",
                table: "StockBalances",
                column: "StockItemId");

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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

            migrationBuilder.DropIndex(
                name: "IX_StockTransactions_StockItemId",
                table: "StockTransactions");

            migrationBuilder.DropIndex(
                name: "IX_StockReservations_StockItemId",
                table: "StockReservations");

            migrationBuilder.DropIndex(
                name: "IX_StockBalances_StockItemId",
                table: "StockBalances");
        }
    }
}
