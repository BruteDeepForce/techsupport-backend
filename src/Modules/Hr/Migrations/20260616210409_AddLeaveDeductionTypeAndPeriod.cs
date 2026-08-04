using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class AddLeaveDeductionTypeAndPeriod : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "DeductionPeriod",
                schema: "hr",
                table: "LeaveDeductions",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "DeductionType",
                schema: "hr",
                table: "LeaveDeductions",
                type: "integer",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeductionPeriod",
                schema: "hr",
                table: "LeaveDeductions");

            migrationBuilder.DropColumn(
                name: "DeductionType",
                schema: "hr",
                table: "LeaveDeductions");
        }
    }
}
