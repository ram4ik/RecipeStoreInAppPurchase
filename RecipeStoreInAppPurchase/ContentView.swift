//
//  ContentView.swift
//  RecipeStoreInAppPurchase
//
//  Created by ramil on 19.05.2021.
//

import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe
    let action: () -> Void
    
    var body: some View {
        HStack {
            ZStack {
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(9)
                    .opacity(recipe.isLocked ? 0.8 : 1)
                    .blur(radius: recipe.isLocked ? 3.0 : 0)
                    .padding()
                Image(systemName: "lock.fill")
                    .font(.largeTitle)
                    .opacity(recipe.isLocked ? 1 : 0)
            }
            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.title)
                Text(recipe.description)
                    .font(.caption)
            }
            Spacer()
            if let price = recipe.price, recipe.isLocked {
                Button(action: {
                    action()
                }, label: {
                    Text(price)
                        .foregroundColor(.white)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 5)
                        .background(Color.black)
                        .cornerRadius(25)
                })
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var store: Store
    
    var body: some View {
        NavigationView {
            List(store.allRecipe, id: \.self) { recipe in
                Group {
                    if !recipe.isLocked {
                        NavigationLink(
                            destination: Text("Secret Recipe"),
                            label: {
                                RecipeRow(recipe: recipe) { }
                            })
                    } else {
                        RecipeRow(recipe: recipe) {
                            if let product = store.product(for: recipe.id) {
                                store.purchaseProduct(product)
                            }
                        }
                    }
                }.navigationBarItems(trailing: Button(action: {
                    store.restorePurchases()
                }, label: {
                    Text("Restore")
                }))
            }.navigationTitle("Recipe Store")
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
