import SwiftUI

struct LunexView: View {
    var body: some View {
        ZStack {
            // Cor de fundo que abrange toda a tela
            Color(hex: "#1b2c5d")
                .edgesIgnoringSafeArea([.leading, .trailing])
            VStack {
                Spacer()
                HStack {
                    Link(destination: URL(string: "https://wa.me/5541995110399")!) {
                        HStack {
                            Image("whatsapp")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("Fale agora conosco")
                        }
                    }
                }
                .padding()
                
                Link(destination: URL(string: "https://youtu.be/5czw-sAOq2U")!) {
                    HStack {
                        Image("3d-video")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Vídeo do manual")
                    }
                }
                .padding()
                
                Link(destination: URL(string: "https://www.lunex.com.br/images/catalogos/catalogo.pdf")!) {
                    HStack {
                        Image("pdf")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Veja nossos produtos")
                    }
                }
                .padding()
                
                Spacer() // Empurra o conteúdo para cima, deixando o HStack das redes sociais próximo ao menu inferior.

                HStack {
                    Link(destination: URL(string: "https://pt-br.facebook.com/lunextecnologia/")!) {
                        Image("facebook")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                    Link(destination: URL(string: "https://www.linkedin.com/company/lunex-tecnologia/")!) {
                        Image("linkedin")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                    Link(destination: URL(string: "https://www.instagram.com/lunextecnologia/")!) {
                        Image("instagram")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding()
                    }
                }
                .padding([.bottom, .horizontal])
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Lunex")
        .background(Color.init(hex: "#f37021").edgesIgnoringSafeArea(.bottom)) // Aplica a cor vermelha apenas na parte inferior
    }
}

      struct LunexView_Previews: PreviewProvider {
          static var previews: some View {
              LunexView()
          }
      }
