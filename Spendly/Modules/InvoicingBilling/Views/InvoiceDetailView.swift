import SwiftUI
import SpendlyCore

struct InvoiceDetailView: View {
    @Bindable var viewModel: InvoicingBillingViewModel
    let invoice: InvoiceDisplayModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {

                // MARK: - Header Card
                VStack(spacing: SpendlySpacing.sm) {
                    Text(invoice.invoiceNumber)
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    SPBadge(invoice.statusLabel, style: invoice.statusBadgeStyle)

                    Text(viewModel.formatCurrency(invoice.total))
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Customer & Job Info
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Details")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    detailRow(label: "Customer", value: invoice.customerName)
                    detailRow(label: "Job", value: "\(invoice.jobTitle) (\(invoice.jobNumber))")

                    if let dueDate = invoice.dueDate {
                        detailRow(label: "Due Date", value: viewModel.formatDate(dueDate))
                    }

                    if let paidAt = invoice.paidAt {
                        detailRow(label: "Paid On", value: viewModel.formatDate(paidAt))
                    }

                    detailRow(label: "Job Completed", value: viewModel.formatDate(invoice.completedDate))
                }
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Line Items
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Line Items")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    ForEach(invoice.lineItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.itemDescription)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                Text("Qty: \(item.quantity)")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                            Spacer()
                            Text(viewModel.formatCurrency(item.unitPrice * Double(item.quantity)))
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                    }

                    Divider()

                    HStack {
                        Text("Subtotal")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text(viewModel.formatCurrency(invoice.subtotal))
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    HStack {
                        Text("Tax (\(Int(invoice.taxRate * 100))%)")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text(viewModel.formatCurrency(invoice.taxAmount))
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    HStack {
                        Text("Total")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        Text(viewModel.formatCurrency(invoice.total))
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Notes
                if let notes = invoice.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Notes")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(notes)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                }

                // MARK: - Actions
                VStack(spacing: SpendlySpacing.sm) {
                    if invoice.status == .draft {
                        Button {
                            viewModel.sendInvoice(invoice)
                        } label: {
                            Label("Send Invoice", systemImage: "paperplane")
                                .font(SpendlyFont.headline())
                                .frame(maxWidth: .infinity)
                                .padding(SpendlySpacing.sm)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SpendlyColors.primary)
                    }

                    if invoice.status == .sent || invoice.status == .overdue {
                        Button {
                            viewModel.showPaymentSheet = true
                        } label: {
                            Label("Record Payment", systemImage: "dollarsign.circle")
                                .font(SpendlyFont.headline())
                                .frame(maxWidth: .infinity)
                                .padding(SpendlySpacing.sm)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SpendlyColors.success)
                    }

                    Button {
                        viewModel.emailInvoice(invoice)
                    } label: {
                        Label("Email to Customer", systemImage: "envelope")
                            .font(SpendlyFont.headline())
                            .frame(maxWidth: .infinity)
                            .padding(SpendlySpacing.sm)
                    }
                    .buttonStyle(.bordered)

                    Button {
                        viewModel.downloadPDF(invoice)
                    } label: {
                        Label("Download PDF", systemImage: "arrow.down.doc")
                            .font(SpendlyFont.headline())
                            .frame(maxWidth: .infinity)
                            .padding(SpendlySpacing.sm)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(SpendlySpacing.md)
        }
        .background(SpendlyColors.background(for: colorScheme))
        .navigationTitle(invoice.invoiceNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Detail Row

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
            Spacer()
            Text(value)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .multilineTextAlignment(.trailing)
        }
    }
}
