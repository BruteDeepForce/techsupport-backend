using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class StockUniqueIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_stock_reservations_IdempotentcyKey",
                schema: "stock",
                table: "stock_reservations",
                column: "IdempotentcyKey",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_stock_reservations_IdempotentcyKey",
                schema: "stock",
                table: "stock_reservations");
        }
    }
}
