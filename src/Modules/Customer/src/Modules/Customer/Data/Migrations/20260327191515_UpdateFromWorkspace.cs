using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Customer.src.Modules.Customer.Data.Migrations
{
    /// <inheritdoc />
    public partial class UpdateFromWorkspace : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "DeviceGuaranteeStartDate",
                schema: "customers",
                table: "customer_devices",
                newName: "WarrantyStartAtUtc");

            migrationBuilder.RenameColumn(
                name: "DeviceGuaranteePeriod",
                schema: "customers",
                table: "customer_devices",
                newName: "GuaranteePeriod");

            migrationBuilder.RenameColumn(
                name: "DeviceGuaranteeEndDate",
                schema: "customers",
                table: "customer_devices",
                newName: "WarrantyEndAtUtc");

            migrationBuilder.AddColumn<string>(
                name: "BarcodeNumber",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Brand",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsActive",
                schema: "customers",
                table: "customer_devices",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Model",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProblemDescription",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(4000)",
                maxLength: 4000,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SerialNumber",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Status",
                schema: "customers",
                table: "customer_devices",
                type: "character varying(64)",
                maxLength: 64,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BarcodeNumber",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "Brand",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "IsActive",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "Model",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "ProblemDescription",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "SerialNumber",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.DropColumn(
                name: "Status",
                schema: "customers",
                table: "customer_devices");

            migrationBuilder.RenameColumn(
                name: "WarrantyStartAtUtc",
                schema: "customers",
                table: "customer_devices",
                newName: "DeviceGuaranteeStartDate");

            migrationBuilder.RenameColumn(
                name: "WarrantyEndAtUtc",
                schema: "customers",
                table: "customer_devices",
                newName: "DeviceGuaranteeEndDate");

            migrationBuilder.RenameColumn(
                name: "GuaranteePeriod",
                schema: "customers",
                table: "customer_devices",
                newName: "DeviceGuaranteePeriod");
        }
    }
}
