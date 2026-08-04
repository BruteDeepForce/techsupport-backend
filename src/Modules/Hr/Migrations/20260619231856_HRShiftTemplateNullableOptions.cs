using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class HRShiftTemplateNullableOptions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ShiftAssignments_ShiftTemplates_ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments");

            migrationBuilder.AlterColumn<Guid>(
                name: "ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddForeignKey(
                name: "FK_ShiftAssignments_ShiftTemplates_ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments",
                column: "ShiftTemplateId",
                principalSchema: "hr",
                principalTable: "ShiftTemplates",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ShiftAssignments_ShiftTemplates_ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments");

            migrationBuilder.AlterColumn<Guid>(
                name: "ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_ShiftAssignments_ShiftTemplates_ShiftTemplateId",
                schema: "hr",
                table: "ShiftAssignments",
                column: "ShiftTemplateId",
                principalSchema: "hr",
                principalTable: "ShiftTemplates",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
