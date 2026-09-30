using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Reports.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddPlannedOperationSnapshots : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "planned_operation_snapshots",
                schema: "reports",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    ScheduledAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    ToTechnicianUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    TechnicianFullName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: true),
                    CustomerName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Title = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    OperationId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_planned_operation_snapshots", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_planned_operation_snapshots_BranchId",
                schema: "reports",
                table: "planned_operation_snapshots",
                column: "BranchId");

            migrationBuilder.CreateIndex(
                name: "IX_planned_operation_snapshots_CustomerId",
                schema: "reports",
                table: "planned_operation_snapshots",
                column: "CustomerId");

            migrationBuilder.CreateIndex(
                name: "IX_planned_operation_snapshots_TenantId",
                schema: "reports",
                table: "planned_operation_snapshots",
                column: "TenantId");

            migrationBuilder.CreateIndex(
                name: "IX_planned_operation_snapshots_ToTechnicianUserId",
                schema: "reports",
                table: "planned_operation_snapshots",
                column: "ToTechnicianUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "planned_operation_snapshots",
                schema: "reports");
        }
    }
}
