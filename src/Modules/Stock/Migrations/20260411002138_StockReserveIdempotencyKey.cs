using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class StockReserveIdempotencyKey : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "IdempotentcyKey",
                schema: "stock",
                table: "stock_reservations",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IdempotentcyKey",
                schema: "stock",
                table: "stock_reservations");
        }
    }
}
