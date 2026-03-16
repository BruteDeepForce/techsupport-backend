using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Device.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Device_20260316 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "ProblemDescription",
                schema: "devices",
                table: "devices",
                type: "character varying(4000)",
                maxLength: 4000,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "text");

            migrationBuilder.AddColumn<int>(
                name: "GuaranteePeriod",
                schema: "devices",
                table: "devices",
                type: "integer",
                nullable: true,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "GuaranteePeriod",
                schema: "devices",
                table: "devices");

            migrationBuilder.AlterColumn<string>(
                name: "ProblemDescription",
                schema: "devices",
                table: "devices",
                type: "text",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "character varying(4000)",
                oldMaxLength: 4000,
                oldNullable: true);
        }
    }
}
