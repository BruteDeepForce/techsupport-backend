using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Technician.src.Modules.Technician.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddTechnicianFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "CreatedAt",
                schema: "technicians",
                table: "technicians",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)));

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "EmploymentStartDate",
                schema: "technicians",
                table: "technicians",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "UpdatedAt",
                schema: "technicians",
                table: "technicians",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)));

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "EmploymentStartDate",
                schema: "technicians",
                table: "technician_provision_requests",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "ExpertsTechnicianProvision",
                schema: "technicians",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    ExpertiseId = table.Column<Guid>(type: "uuid", nullable: true),
                    TechnicianProvisionRequestId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExpertsTechnicianProvision", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ExpertsTechnicianProvision_technician_provision_requests_Te~",
                        column: x => x.TechnicianProvisionRequestId,
                        principalSchema: "technicians",
                        principalTable: "technician_provision_requests",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_ExpertsTechnicianProvision_TechnicianProvisionRequestId",
                schema: "technicians",
                table: "ExpertsTechnicianProvision",
                column: "TechnicianProvisionRequestId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ExpertsTechnicianProvision",
                schema: "technicians");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                schema: "technicians",
                table: "technicians");

            migrationBuilder.DropColumn(
                name: "EmploymentStartDate",
                schema: "technicians",
                table: "technicians");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                schema: "technicians",
                table: "technicians");

            migrationBuilder.DropColumn(
                name: "EmploymentStartDate",
                schema: "technicians",
                table: "technician_provision_requests");
        }
    }
}
