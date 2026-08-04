using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TechSupport.Customer.Data.Migrations
{
    /// <inheritdoc />
    public partial class Customer_TradeProvisionFlow : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "TradeCorelationKey",
                schema: "customers",
                table: "customer_provision_requests",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "TradeId",
                schema: "customers",
                table: "customer_provision_requests",
                type: "uuid",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TradeCorelationKey",
                schema: "customers",
                table: "customer_provision_requests");

            migrationBuilder.DropColumn(
                name: "TradeId",
                schema: "customers",
                table: "customer_provision_requests");
        }
    }
}
