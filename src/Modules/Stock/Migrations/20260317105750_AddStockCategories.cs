using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Stock.Migrations
{
    /// <inheritdoc />
    public partial class AddStockCategories : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CategoryId",
                schema: "stock",
                table: "stock_items",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "stock_categories",
                schema: "stock",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    TenantId = table.Column<Guid>(type: "uuid", nullable: false),
                    BranchId = table.Column<Guid>(type: "uuid", nullable: true),
                    Name = table.Column<string>(type: "character varying(256)", maxLength: 256, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_stock_categories", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_stock_items_CategoryId",
                schema: "stock",
                table: "stock_items",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_stock_categories_TenantId_Name",
                schema: "stock",
                table: "stock_categories",
                columns: new[] { "TenantId", "Name" },
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_stock_items_stock_categories_CategoryId",
                schema: "stock",
                table: "stock_items",
                column: "CategoryId",
                principalSchema: "stock",
                principalTable: "stock_categories",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_stock_items_stock_categories_CategoryId",
                schema: "stock",
                table: "stock_items");

            migrationBuilder.DropTable(
                name: "stock_categories",
                schema: "stock");

            migrationBuilder.DropIndex(
                name: "IX_stock_items_CategoryId",
                schema: "stock",
                table: "stock_items");

            migrationBuilder.DropColumn(
                name: "CategoryId",
                schema: "stock",
                table: "stock_items");
        }
    }
}
