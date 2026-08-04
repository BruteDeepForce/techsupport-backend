using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class AddAdvanceSettingsHR : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AdvanceSettings",
                schema: "hr",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    MaxAdvanceAmountPerPerson = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    MaxAdvanceCountPerYear = table.Column<int>(type: "integer", nullable: false),
                    AllowFutureAdvances = table.Column<bool>(type: "boolean", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AdvanceSettings", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AdvanceSettings_TenantId_BranchId",
                schema: "hr",
                table: "AdvanceSettings",
                columns: new[] { "TenantId", "BranchId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AdvanceSettings",
                schema: "hr");
        }
    }
}
