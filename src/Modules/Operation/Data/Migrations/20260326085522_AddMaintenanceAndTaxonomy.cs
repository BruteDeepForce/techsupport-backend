using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMaintenanceAndTaxonomy : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "MaintenanceTemplateId",
                schema: "operations",
                table: "operations",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "ScheduledAtUtc",
                schema: "operations",
                table: "operations",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Type",
                schema: "operations",
                table: "operations",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "brands",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_brands", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "classes",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_classes", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "product_types",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_product_types", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "maintenance_templates",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    ProductTypeId = table.Column<Guid>(type: "uuid", nullable: true),
                    BrandId = table.Column<Guid>(type: "uuid", nullable: true),
                    ClassId = table.Column<Guid>(type: "uuid", nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_maintenance_templates", x => x.Id);
                    table.ForeignKey(
                        name: "FK_maintenance_templates_brands_BrandId",
                        column: x => x.BrandId,
                        principalSchema: "operations",
                        principalTable: "brands",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_maintenance_templates_classes_ClassId",
                        column: x => x.ClassId,
                        principalSchema: "operations",
                        principalTable: "classes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_maintenance_templates_product_types_ProductTypeId",
                        column: x => x.ProductTypeId,
                        principalSchema: "operations",
                        principalTable: "product_types",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "maintenance_template_items",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    MaintenanceTemplateId = table.Column<Guid>(type: "uuid", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    Title = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    IsRequired = table.Column<bool>(type: "boolean", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_maintenance_template_items", x => x.Id);
                    table.ForeignKey(
                        name: "FK_maintenance_template_items_maintenance_templates_Maintenanc~",
                        column: x => x.MaintenanceTemplateId,
                        principalSchema: "operations",
                        principalTable: "maintenance_templates",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_operations_MaintenanceTemplateId",
                schema: "operations",
                table: "operations",
                column: "MaintenanceTemplateId");

            migrationBuilder.CreateIndex(
                name: "IX_operations_TenantId_Type",
                schema: "operations",
                table: "operations",
                columns: new[] { "TenantId", "Type" });

            migrationBuilder.CreateIndex(
                name: "IX_brands_TenantId_IsActive",
                schema: "operations",
                table: "brands",
                columns: new[] { "TenantId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_brands_TenantId_Name",
                schema: "operations",
                table: "brands",
                columns: new[] { "TenantId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_classes_TenantId_IsActive",
                schema: "operations",
                table: "classes",
                columns: new[] { "TenantId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_classes_TenantId_Name",
                schema: "operations",
                table: "classes",
                columns: new[] { "TenantId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_template_items_MaintenanceTemplateId_SortOrder",
                schema: "operations",
                table: "maintenance_template_items",
                columns: new[] { "MaintenanceTemplateId", "SortOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_templates_BrandId",
                schema: "operations",
                table: "maintenance_templates",
                column: "BrandId");

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_templates_ClassId",
                schema: "operations",
                table: "maintenance_templates",
                column: "ClassId");

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_templates_ProductTypeId",
                schema: "operations",
                table: "maintenance_templates",
                column: "ProductTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_templates_TenantId_IsActive",
                schema: "operations",
                table: "maintenance_templates",
                columns: new[] { "TenantId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_product_types_TenantId_IsActive",
                schema: "operations",
                table: "product_types",
                columns: new[] { "TenantId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_product_types_TenantId_Name",
                schema: "operations",
                table: "product_types",
                columns: new[] { "TenantId", "Name" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_operations_maintenance_templates_MaintenanceTemplateId",
                schema: "operations",
                table: "operations",
                column: "MaintenanceTemplateId",
                principalSchema: "operations",
                principalTable: "maintenance_templates",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_operations_maintenance_templates_MaintenanceTemplateId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropTable(
                name: "maintenance_template_items",
                schema: "operations");

            migrationBuilder.DropTable(
                name: "maintenance_templates",
                schema: "operations");

            migrationBuilder.DropTable(
                name: "brands",
                schema: "operations");

            migrationBuilder.DropTable(
                name: "classes",
                schema: "operations");

            migrationBuilder.DropTable(
                name: "product_types",
                schema: "operations");

            migrationBuilder.DropIndex(
                name: "IX_operations_MaintenanceTemplateId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropIndex(
                name: "IX_operations_TenantId_Type",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "MaintenanceTemplateId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "ScheduledAtUtc",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "Type",
                schema: "operations",
                table: "operations");
        }
    }
}
