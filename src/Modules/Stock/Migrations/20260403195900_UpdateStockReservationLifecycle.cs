using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class UpdateStockReservationLifecycle : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ApprovedAtUtc",
                schema: "stock",
                table: "stock_reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "FinalizedAtUtc",
                schema: "stock",
                table: "stock_reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RejectedAtUtc",
                schema: "stock",
                table: "stock_reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RejectedReason",
                schema: "stock",
                table: "stock_reservations",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReleasedAtUtc",
                schema: "stock",
                table: "stock_reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "RequestedAtUtc",
                schema: "stock",
                table: "stock_reservations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPriceSnapshot",
                schema: "stock",
                table: "stock_reservations",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "UnitPrice",
                schema: "stock",
                table: "stock_items",
                type: "numeric",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ApprovedAtUtc",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "FinalizedAtUtc",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "RejectedAtUtc",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "RejectedReason",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "ReleasedAtUtc",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "RequestedAtUtc",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "UnitPriceSnapshot",
                schema: "stock",
                table: "stock_reservations");

            migrationBuilder.DropColumn(
                name: "UnitPrice",
                schema: "stock",
                table: "stock_items");
        }
    }
}
