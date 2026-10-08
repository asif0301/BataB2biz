import SwiftUI

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CheckoutViewModel()
    @State private var notes = ""
    @State private var showingOrderPlaced = false
    @State private var showingOrders = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                if viewModel.isLoading && viewModel.snapshot == nil {
                    CheckoutLoadingView()
                } else if let snapshot = viewModel.snapshot {
                    content(snapshot)
                } else if !viewModel.errorMessage.isEmpty {
                    errorView
                }
            }

            if showingOrderPlaced, let confirmation = viewModel.confirmation {
                orderPlacedPopup(confirmation)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showingOrders) {
            OrdersView()
        }
        .task { viewModel.load() }
        .alert("Checkout", isPresented: Binding(
            get: { !viewModel.placeOrderError.isEmpty },
            set: { if !$0 { viewModel.placeOrderError = "" } }
        )) {
            Button("OK", role: .cancel) { viewModel.placeOrderError = "" }
        } message: {
            Text(viewModel.placeOrderError)
        }
        .onChange(of: viewModel.confirmation?.orderNumber) { _, newValue in
            if newValue != nil { showingOrderPlaced = true }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 23, weight: .medium))
                    .foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
            Text("Checkout").montserrat(22, weight: .bold).foregroundStyle(AppColors.title)
            Spacer()
            Image(systemName: "bell")
                .font(.system(size: 20))
                .foregroundStyle(AppColors.subtitle)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 22)
    }

    private func content(_ snapshot: CartSnapshot) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                addressSection(snapshot.deliveryAddress)
                notesSection
                orderSection(snapshot.cartItems)
                totalsSection(snapshot.summary)
                Button {
                    viewModel.placeOrder(notes: notes)
                } label: {
                    HStack(spacing: 8) {
                        if viewModel.isPlacingOrder { ProgressView().tint(.white) }
                        Text("Place Order")
                    }
                }
                    .montserrat(17, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)
                    .disabled(viewModel.isPlacingOrder)
                    .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
    }

    private func orderPlacedPopup(_ confirmation: OrderConfirmation) -> some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(width: 104, height: 104)
                    Image(systemName: "checkmark")
                        .font(.system(size: 43, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }

                Text(confirmation.title)
                    .montserrat(25, weight: .bold)
                    .foregroundStyle(AppColors.title)
                    .padding(.top, 30)
                Text(confirmation.orderNumber)
                    .montserrat(19)
                    .foregroundStyle(AppColors.subtitle)
                    .padding(.top, 7)

                VStack(spacing: 13) {
                    popupRow("Status", confirmation.statusLabel, valueColor: AppColors.primary, emphasized: true)
                    popupRow("Items", "\(confirmation.totalProducts) products · \(confirmation.totalPacks) packs · \(confirmation.totalPairs) pairs")
                    popupRow("Total", "Rs \(confirmation.totalPayable.checkoutDisplayPrice)")
                    popupRow("Est. Delivery", confirmation.expectedDeliveryDate ?? "3-5 days")
                }
                .padding(22)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 13))
                .padding(.top, 30)

                Button {
                    showingOrderPlaced = false
                    showingOrders = true
                } label: {
                    Text("My Orders")
                }
                    .montserrat(17, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .buttonStyle(.plain)
                    .padding(.top, 24)

                Button("Continue Shopping") { dismiss() }
                    .montserrat(17, weight: .bold)
                    .foregroundStyle(AppColors.primary)
                    .frame(maxWidth: .infinity, minHeight: 56)
                    .overlay { RoundedRectangle(cornerRadius: 14).stroke(AppColors.primary, lineWidth: 2) }
                    .buttonStyle(.plain)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 34)
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            .padding(.horizontal, 20)
        }
    }

    private func popupRow(_ title: String, _ value: String, valueColor: Color = AppColors.title, emphasized: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title).montserrat(16)
            Spacer(minLength: 8)
            Text(value)
                .montserrat(16, weight: emphasized ? .bold : .regular)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .foregroundStyle(AppColors.title)
    }

    private func addressSection(_ address: CartDeliveryAddress?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Delivery Address").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
                Spacer()
                Button("Change") { }
                    .montserrat(15, weight: .medium)
                    .foregroundStyle(AppColors.primary)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(address?.title ?? "No address selected")
                    .montserrat(18, weight: .bold)
                    .foregroundStyle(AppColors.title)
                Text(address?.fullAddress ?? "Please select a delivery address")
                    .montserrat(15)
                    .foregroundStyle(AppColors.subtitle)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .overlay { RoundedRectangle(cornerRadius: 18).stroke(AppColors.primary, lineWidth: 1.5) }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Special Instructions").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
            TextField("Any notes for delivery...", text: $notes, axis: .vertical)
                .montserrat(15)
                .foregroundStyle(AppColors.title)
                .lineLimit(4, reservesSpace: true)
                .padding(20)
                .overlay { RoundedRectangle(cornerRadius: 18).stroke(AppColors.border, lineWidth: 1) }
        }
    }

    private func orderSection(_ items: [CartItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Order Summary").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
            VStack(spacing: 0) {
                HStack {
                    Text("Item"); Spacer(); Text("Qty(Packs)"); Spacer(); Text("Amount")
                }
                .montserrat(14, weight: .bold)
                .padding(16)
                Divider()
                ForEach(items) { item in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title).lineLimit(1)
                            Text(item.article).foregroundStyle(AppColors.subtitle)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(item.packQuantity)").frame(width: 65)
                        Text("Rs \(item.totalAmount.checkoutDisplayPrice)").frame(width: 105, alignment: .trailing)
                    }
                    .montserrat(14)
                    .padding(16)
                }
            }
            .foregroundStyle(AppColors.title)
            .background(AppColors.background)
            .overlay { RoundedRectangle(cornerRadius: 18).stroke(AppColors.border, lineWidth: 1) }
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }

    private func totalsSection(_ summary: CartSummary) -> some View {
        VStack(spacing: 16) {
            totalRow("Total Products", "\(summary.totalProducts)")
            totalRow("Total Packs", "\(summary.totalPacks)")
            totalRow("No. of Pairs", "\(summary.totalPairs)")
            totalRow("Value", "Rs \(summary.valueHRT.checkoutDisplayPrice)")
            totalRow("Seasonal Discount", "- Rs \(summary.seasonalDiscount.checkoutDisplayPrice)", muted: true)
            totalRow("Volume Discount", "- Rs \(summary.volumeDiscount.checkoutDisplayPrice)", muted: true)
            totalRow("Coupon Code", "- Rs \(summary.couponCode.checkoutDisplayPrice)", muted: true)
            totalRow("Gross Total", "Rs \(summary.grossTotal.checkoutDisplayPrice)")
            totalRow("Tax", "Rs \(summary.salesTaxAmount.checkoutDisplayPrice)", muted: true)
            Divider()
            totalRow("Total Payable", "Rs \(summary.totalPayable.checkoutDisplayPrice)", emphasized: true)
        }
        .padding(24)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func totalRow(_ title: String, _ value: String, muted: Bool = false, emphasized: Bool = false) -> some View {
        HStack {
            Text(title).montserrat(emphasized ? 16 : 14, weight: emphasized ? .bold : .regular)
            Spacer()
            Text(value).montserrat(emphasized ? 17 : 14, weight: emphasized ? .bold : .regular)
        }
        .foregroundStyle(emphasized ? AppColors.primary : (muted ? AppColors.subtitle : AppColors.title))
    }

    private var errorView: some View {
        VStack(spacing: 12) {
            Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle)
            Button("Try Again") { viewModel.load() }.foregroundStyle(AppColors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview { CheckoutView() }

private extension Double {
    var checkoutDisplayPrice: String {
        formatted(.number.precision(.fractionLength(0...2)))
    }
}

private struct CheckoutLoadingView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SkeletonBlock(width: nil, height: 150, cornerRadius: 18)
                SkeletonBlock(width: nil, height: 115, cornerRadius: 18)
                SkeletonBlock(width: nil, height: 220, cornerRadius: 18)
                SkeletonBlock(width: nil, height: 420, cornerRadius: 14)
            }
            .padding(20)
        }
        .scrollIndicators(.hidden)
    }
}
