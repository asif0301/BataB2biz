import SwiftUI

struct CartView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CartViewModel()
    @State private var showingCheckout = false

    var body: some View {
        VStack(spacing: 0) {
            header
            if viewModel.isLoading && viewModel.snapshot == nil {
                CartLoadingView()
            } else if let snapshot = viewModel.snapshot {
                if snapshot.cartItems.isEmpty {
                    emptyView
                } else {
                    cartContent(snapshot)
                }
            } else if !viewModel.errorMessage.isEmpty {
                errorView
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $showingCheckout) {
            CheckoutView()
        }
        .task { viewModel.load() }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left").font(.system(size: 24, weight: .medium)).foregroundStyle(AppColors.title)
            }
            .buttonStyle(.plain)
            Text("My Cart (\(viewModel.snapshot?.summary.totalProducts ?? 0))").montserrat(20, weight: .bold).foregroundStyle(AppColors.title)
            Spacer()
            Button("Clear all") { viewModel.clear() }
                .montserrat(15).foregroundStyle(AppColors.title)
                .disabled(viewModel.snapshot?.cartItems.isEmpty != false || viewModel.isMutating)
        }
        .padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 22)
    }

    private func cartContent(_ snapshot: CartSnapshot) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(snapshot.cartItems) { item in
                        CartItemCard(item: item) { viewModel.remove(itemID: item.id) }
                    }
                    summaryCard(snapshot.summary)
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
            checkoutButton(snapshot.summary)
        }
    }

    private func summaryCard(_ summary: CartSummary) -> some View {
        VStack(spacing: 17) {
            summaryRow("Total Products", value: "\(summary.totalProducts)")
            summaryRow("Total Packs", value: "\(summary.totalPacks)")
            summaryRow("No. of Pairs", value: "\(summary.totalPairs)")
            summaryRow("Value", value: "Rs \(summary.valueHRT.displayPrice)")
            summaryRow("Seasonal Discount", value: "- Rs \(summary.seasonalDiscount.displayPrice)", muted: true)
            summaryRow("Volume Discount", value: "- Rs \(summary.volumeDiscount.displayPrice)", muted: true)
            summaryRow("Coupon Code", value: "- Rs \(summary.couponCode.displayPrice)", muted: true)
            summaryRow("Gross Total", value: "Rs \(summary.grossTotal.displayPrice)")
            summaryRow("Tax", value: "Rs \(summary.salesTaxAmount.displayPrice)", muted: true)
            Divider()
            summaryRow("Total Payable", value: "Rs \(summary.totalPayable.displayPrice)", emphasized: true)
        }
        .padding(24).background(AppColors.background).clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func summaryRow(_ title: String, value: String, muted: Bool = false, emphasized: Bool = false) -> some View {
        HStack {
            Text(title).montserrat(emphasized ? 16 : 14, weight: emphasized ? .bold : .regular).foregroundStyle(muted ? AppColors.subtitle : AppColors.title)
            Spacer()
            Text(value).montserrat(emphasized ? 17 : 14, weight: emphasized ? .bold : .regular).foregroundStyle(emphasized ? AppColors.primary : AppColors.title)
        }
    }

    private func checkoutButton(_ summary: CartSummary) -> some View {
        Button { showingCheckout = true } label: {
            Text("Checkout").montserrat(16, weight: .bold).foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52).background(AppColors.primary).clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain).padding(.horizontal, 20).padding(.vertical, 10)
    }

    private var emptyView: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(AppImages.emptyCart)
                .resizable()
                .scaledToFit()
                .frame(width: 190, height: 175)

            Text("No Product")
                .montserrat(22, weight: .bold)
                .foregroundStyle(AppColors.subtitle)
                .padding(.top, 20)

            Text("Go find the products you like.")
                .montserrat(13)
                .foregroundStyle(AppColors.subtitle)
                .padding(.top, 2)

            Spacer()

            Button { dismiss() } label: {
                Text("Back to Home")
                    .montserrat(16, weight: .bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(AppColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 12) { Text(viewModel.errorMessage).montserrat(13).foregroundStyle(AppColors.subtitle); Button("Try Again") { viewModel.load() }.foregroundStyle(AppColors.primary) }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CartItemCard: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: item.image.flatMap(URL.init)) { image in image.resizable().scaledToFit() } placeholder: { Image(systemName: "photo").foregroundStyle(AppColors.subtitle) }
                    .frame(width: 105, height: 88)
                VStack(alignment: .leading, spacing: 6) {
                    HStack { Text("Article \(item.article)").montserrat(17, weight: .bold).lineLimit(1); Spacer(); Button(action: onRemove) { Image(systemName: "xmark").font(.system(size: 20)).foregroundStyle(AppColors.subtitle) }.buttonStyle(.plain) }
                    Text("Rs \(item.unitPrice.displayPrice)/pair").montserrat(14).foregroundStyle(AppColors.subtitle)
                    HStack { Text(item.packCode ?? "A").montserrat(13, weight: .bold).foregroundStyle(.white).padding(.horizontal, 12).padding(.vertical, 7).background(AppColors.primary).clipShape(RoundedRectangle(cornerRadius: 7)); Text("\(item.pairsPerPack) prs/pack").montserrat(12, weight: .semibold).padding(.horizontal, 10).padding(.vertical, 7).background(AppColors.surface).clipShape(RoundedRectangle(cornerRadius: 7)) }
                    Text("\(item.packQuantity) packs  \(item.totalPairs) pairs").montserrat(13)
                }
            }
            VStack(spacing: 10) {
                HStack { Text("Quantity (Packs)").montserrat(14, weight: .bold); Spacer(); HStack(spacing: 18) { Text("−").foregroundStyle(AppColors.primary); Text("\(item.packQuantity)").montserrat(14, weight: .bold); Text("+").foregroundStyle(AppColors.primary) }.padding(.horizontal, 17).padding(.vertical, 10).overlay { RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1) } }
                Divider()
                HStack { Text("Total Pairs \(item.totalPairs)").montserrat(14).foregroundStyle(AppColors.subtitle); Spacer(); Text("Rs \(item.totalAmount.displayPrice)").montserrat(16, weight: .bold).foregroundStyle(AppColors.primary) }
            }
            .padding(14).background(AppColors.surface).clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(14).background(AppColors.background).overlay { RoundedRectangle(cornerRadius: 17).stroke(AppColors.border, lineWidth: 1) }.clipShape(RoundedRectangle(cornerRadius: 17))
    }
}

private struct CartLoadingView: View { var body: some View { ScrollView { VStack(spacing: 14) { SkeletonBlock(width: nil, height: 240, cornerRadius: 17); SkeletonBlock(width: nil, height: 420, cornerRadius: 12) }.padding(20) } } }

private extension Double { var displayPrice: String { formatted(.number.precision(.fractionLength(0...2))) } }

#Preview { CartView() }
