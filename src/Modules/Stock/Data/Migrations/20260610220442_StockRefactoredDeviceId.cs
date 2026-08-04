using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Data.Migrations
{
    /// <inheritdoc />
    public partial class StockRefactoredDeviceId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "Barcode",
                schema: "stock",
                table: "stock_items",
                type: "text",
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<Guid>(
                name: "DeviceId",
                schema: "stock",
                table: "stock_items",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ImeiOrSerial",
                schema: "stock",
                table: "stock_items",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeviceId",
                schema: "stock",
                table: "stock_items");

            migrationBuilder.DropColumn(
                name: "ImeiOrSerial",
                schema: "stock",
                table: "stock_items");

            migrationBuilder.AlterColumn<string>(
                name: "Barcode",
                schema: "stock",
                table: "stock_items",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "text",
                oldNullable: true);
        }
    }
}
