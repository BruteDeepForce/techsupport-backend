using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Trade.Data.Migrations
{
    /// <inheritdoc />
    public partial class TradeRefactoreCategoryAndSKU : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CategoryId",
                schema: "trade",
                table: "trades",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SKU",
                schema: "trade",
                table: "device_registerations",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CategoryId",
                schema: "trade",
                table: "trades");

            migrationBuilder.DropColumn(
                name: "SKU",
                schema: "trade",
                table: "device_registerations");
        }
    }
}
