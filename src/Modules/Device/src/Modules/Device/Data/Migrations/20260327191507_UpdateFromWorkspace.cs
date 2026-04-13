using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.src.Modules.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateFromWorkspace : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "WarrantyEndAtUtc",
                schema: "devices",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "WarrantyStartAtUtc",
                schema: "devices",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "WarrantyEndAtUtc",
                schema: "devices",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "WarrantyStartAtUtc",
                schema: "devices",
                table: "devices");
        }
    }
}
