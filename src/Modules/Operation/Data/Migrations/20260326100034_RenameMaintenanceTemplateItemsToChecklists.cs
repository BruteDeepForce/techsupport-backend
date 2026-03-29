using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.src.Modules.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class RenameMaintenanceTemplateItemsToChecklists : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "maintenance_template_items",
                schema: "operations");

            migrationBuilder.CreateTable(
                name: "maintenance_template_checklists",
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
                    table.PrimaryKey("PK_maintenance_template_checklists", x => x.Id);
                    table.ForeignKey(
                        name: "FK_maintenance_template_checklists_maintenance_templates_Maint~",
                        column: x => x.MaintenanceTemplateId,
                        principalSchema: "operations",
                        principalTable: "maintenance_templates",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_maintenance_template_checklists_MaintenanceTemplateId_SortO~",
                schema: "operations",
                table: "maintenance_template_checklists",
                columns: new[] { "MaintenanceTemplateId", "SortOrder" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "maintenance_template_checklists",
                schema: "operations");

            migrationBuilder.CreateTable(
                name: "maintenance_template_items",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    MaintenanceTemplateId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    Description = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    IsRequired = table.Column<bool>(type: "boolean", nullable: false),
                    SortOrder = table.Column<int>(type: "integer", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false)
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
                name: "IX_maintenance_template_items_MaintenanceTemplateId_SortOrder",
                schema: "operations",
                table: "maintenance_template_items",
                columns: new[] { "MaintenanceTemplateId", "SortOrder" });
        }
    }
}
