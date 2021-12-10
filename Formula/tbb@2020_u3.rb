class TbbAT2020U3 < Formula
  desc "Rich and complete approach to parallelism in C++"
  homepage "https://github.com/oneapi-src/oneTBB"
  url "https://github.com/intel/tbb/archive/v2020.3.tar.gz"
  version "2020_U3"
  sha256 "ebc4f6aa47972daed1f7bf71d100ae5bf6931c2e3144cf299c8cc7d041dca2f3"
  license "Apache-2.0"
  revision 2

  bottle do
    root_url "https://github.com/Macaulay2/homebrew-tap/releases/download/tbb@2020_u3-2020_U3_2"
    sha256 cellar: :any,                 big_sur:      "a4ebb2e17ef8f78a50de7ab691afa02eb1a926d7b13e8de78ea5a16d3f29e8b7"
    sha256 cellar: :any,                 catalina:     "af584ddb641638924c343d7665f48897673ad04a913d1c7f2a7868efc48503b0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d3cadb4d514aab1e8851910c88d152dfe1dbfc9f2ec2e0383c94231827b00dc5"
  end

  keg_only :versioned_formula

  unless OS.mac?
    fails_with gcc: "4"
    fails_with gcc: "5"
  end

  depends_on "cmake" => :build

  # Remove when upstream fix is released
  # https://github.com/oneapi-src/oneTBB/pull/258
  patch do
    url "https://github.com/oneapi-src/oneTBB/commit/86f6dcdc17a8f5ef2382faaef860cfa5243984fe.patch?full_index=1"
    sha256 "d62cb666de4010998c339cde6f41c7623a07e9fc69e498f2e149821c0c2c6dd0"
  end

  def install
    compiler = (ENV.compiler == :clang) ? "clang" : "gcc"
    system "make", "tbb_build_prefix=BUILDPREFIX", "compiler=#{compiler}"
    lib.install Dir["build/BUILDPREFIX_release/*." + (OS.mac? ? "dylib" : "so*")]

    # Build and install static libraries
    system "make", "tbb_build_prefix=BUILDPREFIX", "compiler=#{compiler}",
                   "extra_inc=big_iron.inc"
    lib.install Dir["build/BUILDPREFIX_release/*.a"]
    include.install "include/tbb"

    system "cmake", *std_cmake_args,
                    "-DINSTALL_DIR=lib/cmake/TBB",
                    "-DSYSTEM_NAME=" + (OS.mac? ? "Darwin" : "Linux"),
                    "-DTBB_VERSION_FILE=#{include}/tbb/tbb_stddef.h",
                    "-P", "cmake/tbb_config_installer.cmake"

    (lib/"cmake"/"TBB").install Dir["lib/cmake/TBB/*.cmake"]
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <tbb/task_scheduler_init.h>
      #include <iostream>

      int main()
      {
        std::cout << tbb::task_scheduler_init::default_num_threads();
        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-L#{lib}", "-I#{include}", "-ltbb", "-o", "test"
    system "./test"
  end
end
