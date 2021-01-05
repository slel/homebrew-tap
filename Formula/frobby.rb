class Frobby < Formula
  desc "Computations With Monomial Ideals"
  homepage "https://www.broune.com/frobby/"
  url "https://github.com/Macaulay2/frobby.git", using: :git, branch: "master"
  version "0.9.1"
  license "GPL-2.0-only"

  bottle do
    root_url "https://github.com/mahrud/homebrew-tap/releases/download/frobby-0.9.1"
    cellar :any
    sha256 "0b98da5ee592e2bed941355d5588a7b3eeb74416b9e70d8099e21183b8f55744" => :catalina
    sha256 "2af401562c2b3b2eda1c04ef5ccfe4d62fa1b6ef76358c8fad4ea30d3c973bef" => :x86_64_linux
  end

  depends_on "gmp"

  def install
    system "make", "prefix=#{prefix}", "BIN_INSTALL_DIR=#{bin}",
           "GMP_INC_DIR=#{Formula["gmp"].include}",
           "LDFLAGS=-L#{Formula["gmp"].lib}",
           "CXXFLAGS=-std=gnu++11"
    system "make", "install", "DESTDIR=#{prefix}"
  end

  test do
    system "true"
  end
end