-dontwarn javax.annotation.processing.AbstractProcessor
-dontwarn javax.annotation.processing.SupportedAnnotationTypes
-dontwarn javax.annotation.processing.**
-dontwarn javax.lang.model.**
-dontwarn javax.lang.model.SourceVersion
-dontwarn javax.lang.model.element.Element
-dontwarn javax.lang.model.element.ElementKind
-dontwarn javax.lang.model.element.Modifier
-dontwarn javax.lang.model.type.TypeMirror
-dontwarn javax.lang.model.type.TypeVisitor
-dontwarn javax.lang.model.util.SimpleTypeVisitor8
-dontwarn javax.tools.**
-dontwarn com.google.auto.value.**
-dontwarn autovalue.shaded.com.google$.**
-dontwarn autovalue.shaded.com.squareup.javapoet$.**
-dontwarn com.google.mediapipe.proto.**

# MediaPipe/TFLite runtime types can be referenced reflectively in release builds.
-keep class com.google.mediapipe.** { *; }
-keep class org.tensorflow.lite.** { *; }
