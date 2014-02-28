class Test_JVM_version {

   public static void main(String[] args){
      System.out.println( "os.name: "                         + System.getProperty("os.name"                        ) );
      System.out.println( "os.version: "                      + System.getProperty("os.version"                     ) );
      System.out.println( "os.arch: "                         + System.getProperty("os.arch"                        ) );
      System.out.println( "sun.arch.data.model:"              + System.getProperty("sun.arch.data.model"            ) );
      System.out.println( "java.vm.name: "                    + System.getProperty("java.vm.name"                   ) );
      System.out.println( "java.vm.specification.name: "      + System.getProperty("java.vm.specification.name"     ) );
      System.out.println( "java.vm.specification.vendor: "    + System.getProperty("java.vm.specification.vendor"   ) );
      System.out.println( "java.vm.specification.version: "   + System.getProperty("java.vm.specification.version"  ) );
      System.out.println( "java.vm.version: "                 + System.getProperty("java.vm.version"                ) );
      System.out.println( "java.vm.vendor: "                  + System.getProperty("java.vm.vendor"                 ) );
      System.out.println( "java.vm.vendor.url: "              + System.getProperty("java.vm.vendor.url"             ) );
      System.out.println( "java.version: "                    + System.getProperty("java.version"                   ) );
      System.out.println( "java.vm.info: "                    + System.getProperty("java.vm.info"                   ) );
   }
}
