using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class AddBordroEmployeeDepartmentIdByPass : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId",
                schema: "hr",
                table: "BordroEmployees");

            migrationBuilder.AlterColumn<Guid>(
                name: "DepartmentId",
                schema: "hr",
                table: "BordroEmployees",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId",
                schema: "hr",
                table: "BordroEmployees",
                column: "DepartmentId",
                principalSchema: "hr",
                principalTable: "Departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId",
                schema: "hr",
                table: "BordroEmployees");

            migrationBuilder.AlterColumn<Guid>(
                name: "DepartmentId",
                schema: "hr",
                table: "BordroEmployees",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId",
                schema: "hr",
                table: "BordroEmployees",
                column: "DepartmentId",
                principalSchema: "hr",
                principalTable: "Departments",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
