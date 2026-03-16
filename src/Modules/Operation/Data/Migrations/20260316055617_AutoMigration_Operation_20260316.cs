using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Operation.Data.Migrations
{
    /// <inheritdoc />
    public partial class AutoMigration_Operation_20260316 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_operations_field_technicians_FieldTechnicianUserId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropTable(
                name: "field_technicians",
                schema: "operations");

            migrationBuilder.AddColumn<string>(
                name: "Priority",
                schema: "operations",
                table: "operations",
                type: "character varying(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<Guid>(
                name: "TicketId",
                schema: "operations",
                table: "operations",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "tickets",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: false),
                    DeviceId = table.Column<Guid>(type: "uuid", nullable: true),
                    OperationId = table.Column<Guid>(type: "uuid", nullable: true),
                    Title = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    Description = table.Column<string>(type: "character varying(4000)", maxLength: 4000, nullable: false),
                    Priority = table.Column<int>(type: "integer", maxLength: 50, nullable: false),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    CreatedByUserId = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false),
                    UpdatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_tickets", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ticket_attachments",
                schema: "operations",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TicketId = table.Column<Guid>(type: "uuid", nullable: true),
                    FileName = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false),
                    ContentType = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    Url = table.Column<string>(type: "text", nullable: false),
                    Size = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAtUtc = table.Column<DateTimeOffset>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ticket_attachments", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ticket_attachments_tickets_TicketId",
                        column: x => x.TicketId,
                        principalSchema: "operations",
                        principalTable: "tickets",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_operations_TicketId",
                schema: "operations",
                table: "operations",
                column: "TicketId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ticket_attachments_TicketId",
                schema: "operations",
                table: "ticket_attachments",
                column: "TicketId");

            migrationBuilder.CreateIndex(
                name: "IX_tickets_TenantId_CreatedByUserId",
                schema: "operations",
                table: "tickets",
                columns: new[] { "TenantId", "CreatedByUserId" });

            migrationBuilder.CreateIndex(
                name: "IX_tickets_TenantId_CustomerId",
                schema: "operations",
                table: "tickets",
                columns: new[] { "TenantId", "CustomerId" });

            migrationBuilder.CreateIndex(
                name: "IX_tickets_TenantId_DeviceId",
                schema: "operations",
                table: "tickets",
                columns: new[] { "TenantId", "DeviceId" });

            migrationBuilder.AddForeignKey(
                name: "FK_operations_tickets_TicketId",
                schema: "operations",
                table: "operations",
                column: "TicketId",
                principalSchema: "operations",
                principalTable: "tickets",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_operations_tickets_TicketId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropTable(
                name: "ticket_attachments",
                schema: "operations");

            migrationBuilder.DropTable(
                name: "tickets",
                schema: "operations");

            migrationBuilder.DropIndex(
                name: "IX_operations_TicketId",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "Priority",
                schema: "operations",
                table: "operations");

            migrationBuilder.DropColumn(
                name: "TicketId",
                schema: "operations",
                table: "operations");

            migrationBuilder.CreateTable(
                name: "field_technicians",
                schema: "operations",
                columns: table => new
                {
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_field_technicians", x => x.UserId);
                });

            migrationBuilder.CreateIndex(
                name: "IX_field_technicians_UserId",
                schema: "operations",
                table: "field_technicians",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_operations_field_technicians_FieldTechnicianUserId",
                schema: "operations",
                table: "operations",
                column: "FieldTechnicianUserId",
                principalSchema: "operations",
                principalTable: "field_technicians",
                principalColumn: "UserId",
                onDelete: ReferentialAction.SetNull);
        }
    }
}
