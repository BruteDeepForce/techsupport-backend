using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Hr.Migrations
{
    /// <inheritdoc />
    public partial class AddBordroEmployeeDepartmentIdByPassv2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "DepartmentId1",
                schema: "hr",
                table: "BordroEmployees",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_BordroEmployees_DepartmentId1",
                schema: "hr",
                table: "BordroEmployees",
                column: "DepartmentId1");

            migrationBuilder.AddForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId1",
                schema: "hr",
                table: "BordroEmployees",
                column: "DepartmentId1",
                principalSchema: "hr",
                principalTable: "Departments",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_BordroEmployees_Departments_DepartmentId1",
                schema: "hr",
                table: "BordroEmployees");

            migrationBuilder.DropIndex(
                name: "IX_BordroEmployees_DepartmentId1",
                schema: "hr",
                table: "BordroEmployees");

            migrationBuilder.DropColumn(
                name: "DepartmentId1",
                schema: "hr",
                table: "BordroEmployees");
        }
    }
}
