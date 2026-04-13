using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class Align_Device_Model : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ProblemDescription",
                schema: "devices",
                table: "devices",
                type: "text",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "UpdatedAtUtc",
                schema: "devices",
                table: "devices",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ProblemDescription",
                schema: "devices",
                table: "devices");

            migrationBuilder.DropColumn(
                name: "UpdatedAtUtc",
                schema: "devices",
                table: "devices");
        }
    }
}
