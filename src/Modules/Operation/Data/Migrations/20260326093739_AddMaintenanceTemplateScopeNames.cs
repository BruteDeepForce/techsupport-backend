using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMaintenanceTemplateScopeNames : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BrandName",
                schema: "operations",
                table: "maintenance_templates",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClassName",
                schema: "operations",
                table: "maintenance_templates",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ProductTypeName",
                schema: "operations",
                table: "maintenance_templates",
                type: "character varying(128)",
                maxLength: 128,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BrandName",
                schema: "operations",
                table: "maintenance_templates");

            migrationBuilder.DropColumn(
                name: "ClassName",
                schema: "operations",
                table: "maintenance_templates");

            migrationBuilder.DropColumn(
                name: "ProductTypeName",
                schema: "operations",
                table: "maintenance_templates");
        }
    }
}
