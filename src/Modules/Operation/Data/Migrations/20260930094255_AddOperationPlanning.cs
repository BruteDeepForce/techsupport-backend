using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddOperationPlanning : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ScheduledAtUtc",
                schema: "operations",
                table: "operations");

            migrationBuilder.AddColumn<string>(
                name: "Future",
                schema: "operations",
                table: "operations",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateTable(
                name: "planned_operations",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    ScheduledAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ToTechnicianUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    TechnicianFullName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: true),
                    CustomerName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Title = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    OperationRecordId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_planned_operations", x => x.Id);
                    table.ForeignKey(
                        name: "FK_planned_operations_operations_OperationRecordId",
                        column: x => x.OperationRecordId,
                        principalSchema: "operations",
                        principalTable: "operations",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_planned_operations_OperationRecordId",
                schema: "operations",
                table: "planned_operations",
                column: "OperationRecordId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_planned_operations_TenantId_BranchId",
                schema: "operations",
                table: "planned_operations",
                columns: new[] { "TenantId", "BranchId" });

            migrationBuilder.CreateIndex(
                name: "IX_planned_operations_TenantId_CustomerId",
                schema: "operations",
                table: "planned_operations",
                columns: new[] { "TenantId", "CustomerId" });

            migrationBuilder.CreateIndex(
                name: "IX_planned_operations_TenantId_ToTechnicianUserId",
                schema: "operations",
                table: "planned_operations",
                columns: new[] { "TenantId", "ToTechnicianUserId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "planned_operations",
                schema: "operations");

            migrationBuilder.DropColumn(
                name: "Future",
                schema: "operations",
                table: "operations");

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "ScheduledAtUtc",
                schema: "operations",
                table: "operations",
                type: "timestamp with time zone",
                nullable: true);
        }
    }
}
