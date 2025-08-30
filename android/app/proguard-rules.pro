# Keep SLF4J logging classes to avoid R8 missing class errors
-keep class org.slf4j.** { *; }
-dontwarn org.slf4j.**
