using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.src.Modules.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianNewTable2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_technician_expert_mappings_TechnicianExpert_TechnicianExper~",
                schema: "technicians",
                table: "technician_expert_mappings");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TechnicianExpert",
                schema: "technicians",
                table: "TechnicianExpert");

            migrationBuilder.RenameTable(
                name: "TechnicianExpert",
                schema: "technicians",
                newName: "TechnicianExperts",
                newSchema: "technicians");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TechnicianExperts",
                schema: "technicians",
                table: "TechnicianExperts",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_technician_expert_mappings_TechnicianExperts_TechnicianExpe~",
                schema: "technicians",
                table: "technician_expert_mappings",
                column: "TechnicianExpertId",
                principalSchema: "technicians",
                principalTable: "TechnicianExperts",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_technician_expert_mappings_TechnicianExperts_TechnicianExpe~",
                schema: "technicians",
                table: "technician_expert_mappings");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TechnicianExperts",
                schema: "technicians",
                table: "TechnicianExperts");

            migrationBuilder.RenameTable(
                name: "TechnicianExperts",
                schema: "technicians",
                newName: "TechnicianExpert",
                newSchema: "technicians");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TechnicianExpert",
                schema: "technicians",
                table: "TechnicianExpert",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_technician_expert_mappings_TechnicianExpert_TechnicianExper~",
                schema: "technicians",
                table: "technician_expert_mappings",
                column: "TechnicianExpertId",
                principalSchema: "technicians",
                principalTable: "TechnicianExpert",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
