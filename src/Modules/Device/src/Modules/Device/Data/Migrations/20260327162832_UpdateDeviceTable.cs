using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.src.Modules.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateDeviceTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BarcodeNumber",
                schema: "devices",
                table: "devices",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CustomerId",
                schema: "devices",
                table: "devices",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CustomerName",
                schema: "devices",
                table: "devices",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Status",
                schema: "devices",
                table: "devices",
                type: "character varying(64)",
                maxLength: 64,
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BarcodeNumber",
                schema: "devices",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "CustomerId",
                schema: "devices",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "CustomerName",
                schema: "devices",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "Status",
                schema: "devices",
                table: "devices");
        }
    }
}
