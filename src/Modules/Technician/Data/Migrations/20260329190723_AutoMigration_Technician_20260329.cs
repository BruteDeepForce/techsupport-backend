using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Technician_20260329 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ExpertsTechnicianProvision_technician_provision_requests_Te~",
                schema: "technicians",
                table: "ExpertsTechnicianProvision");

            migrationBuilder.AddForeignKey(
                name: "FK_ExpertsTechnicianProvision_technician_provision_requests_Te~",
                schema: "technicians",
                table: "ExpertsTechnicianProvision",
                column: "TechnicianProvisionRequestId",
                principalSchema: "technicians",
                principalTable: "technician_provision_requests",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ExpertsTechnicianProvision_technician_provision_requests_Te~",
                schema: "technicians",
                table: "ExpertsTechnicianProvision");

            migrationBuilder.AddForeignKey(
                name: "FK_ExpertsTechnicianProvision_technician_provision_requests_Te~",
                schema: "technicians",
                table: "ExpertsTechnicianProvision",
                column: "TechnicianProvisionRequestId",
                principalSchema: "technicians",
                principalTable: "technician_provision_requests",
                principalColumn: "Id");
        }
    }
}
