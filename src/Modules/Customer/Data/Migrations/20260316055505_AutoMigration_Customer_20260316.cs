using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Customer.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Customer_20260316 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DeviceGuaranteeEndDate",
                schema: "customers",
                table: "customer_devices",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DeviceGuaranteePeriod",
                schema: "customers",
                table: "customer_devices",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DeviceGuaranteeStartDate",
                schema: "customers",
                table: "customer_devices",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeviceGuaranteeEndDate",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "DeviceGuaranteePeriod",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "DeviceGuaranteeStartDate",
                schema: "customers",
                table: "customer_devices");
        }
    }
}
