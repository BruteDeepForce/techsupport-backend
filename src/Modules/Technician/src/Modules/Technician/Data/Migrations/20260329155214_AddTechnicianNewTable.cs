using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.src.Modules.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianNewTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TechnicianExpert",
                schema: "technicians",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    ExpertiseName = table.Column<string>(type: "text", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TechnicianExpert", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "technician_expert_mappings",
                schema: "technicians",
                columns: table => new
                {
                    TechnicianId = table.Column<Guid>(type: "uuid", nullable: false),
                    tenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    TechnicianExpertId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Level = table.Column<int>(type: "integer", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_technician_expert_mappings", x => new { x.TechnicianId, x.TechnicianExpertId, x.tenantId });
                    table.ForeignKey(
                        name: "FK_technician_expert_mappings_TechnicianExpert_TechnicianExper~",
                        column: x => x.TechnicianExpertId,
                        principalSchema: "technicians",
                        principalTable: "TechnicianExpert",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_technician_expert_mappings_technicians_TechnicianId",
                        column: x => x.TechnicianId,
                        principalSchema: "technicians",
                        principalTable: "technicians",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_technician_expert_mappings_TechnicianExpertId",
                schema: "technicians",
                table: "technician_expert_mappings",
                column: "TechnicianExpertId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "technician_expert_mappings",
                schema: "technicians");

            migrationBuilder.DropTable(
                name: "TechnicianExpert",
                schema: "technicians");
        }
    }
}
