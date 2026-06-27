using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class HRPerformanceTableCreated : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "EmployeePerformanceReports",
                schema: "hr",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    EmployeeId = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Year = table.Column<int>(type: "integer", nullable: false),
                    Month = table.Column<int>(type: "integer", nullable: false),
                    TotalAssignedTasks = table.Column<int>(type: "integer", nullable: false),
                    TotalCompletedTasks = table.Column<int>(type: "integer", nullable: false),
                    TotalPendingTasks = table.Column<int>(type: "integer", nullable: false),
                    TotalOverdueTasks = table.Column<int>(type: "integer", nullable: false),
                    TotalCompletedOnTime = table.Column<int>(type: "integer", nullable: true),
                    TotalCompletedLate = table.Column<int>(type: "integer", nullable: true),
                    RewardCount = table.Column<int>(type: "integer", nullable: false),
                    PenaltyCount = table.Column<int>(type: "integer", nullable: false),
                    LeaveCount = table.Column<int>(type: "integer", nullable: false),
                    ShiftAttendanceCount = table.Column<int>(type: "integer", nullable: false),
                    NotJoinedShiftCount = table.Column<int>(type: "integer", nullable: false),
                    OvertimeCount = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EmployeePerformanceReports", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EmployeePerformanceReports_Employees_EmployeeId",
                        column: x => x.EmployeeId,
                        principalSchema: "hr",
                        principalTable: "Employees",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EmployeePerformanceReports_EmployeeId",
                schema: "hr",
                table: "EmployeePerformanceReports",
                column: "EmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_EmployeePerformanceReports_TenantId_EmployeeId_Year_Month",
                schema: "hr",
                table: "EmployeePerformanceReports",
                columns: new[] { "TenantId", "EmployeeId", "Year", "Month" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EmployeePerformanceReports",
                schema: "hr");
        }
    }
}
