#!/bin/bash

set -e

echo "🎯 Creating proper Xcode project for CleanME..."

# Create project directory
PROJECT_DIR="CleanME.xcodeproj"
mkdir -p "$PROJECT_DIR"

# Generate project.pbxproj
cat > "$PROJECT_DIR/project.pbxproj" << 'EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		ASSETS_BUILD /* Assets.xcassets */ = {isa = PBXBuildFile; fileRef = ASSETS_REF /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		APP_PRODUCT /* CleanME.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = CleanME.app; sourceTree = BUILT_PRODUCTS_DIR; };
		ASSETS_REF /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXGroup section */
		MAIN_GROUP = {
			isa = PBXGroup;
			children = (
				SOURCES_GROUP /* Sources */,
				PRODUCTS_GROUP /* Products */,
			);
			sourceTree = "<group>";
		};
		SOURCES_GROUP /* Sources */ = {
			isa = PBXGroup;
			children = (
				RESOURCES_GROUP /* Resources */,
			);
			path = Sources/CleanME;
			sourceTree = "<group>";
		};
		RESOURCES_GROUP /* Resources */ = {
			isa = PBXGroup;
			children = (
				ASSETS_REF /* Assets.xcassets */,
			);
			path = Resources;
			sourceTree = "<group>";
		};
		PRODUCTS_GROUP /* Products */ = {
			isa = PBXGroup;
			children = (
				APP_PRODUCT /* CleanME.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		APP_TARGET /* CleanME */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = APP_CONFIG_LIST /* Build configuration list for PBXNativeTarget "CleanME" */;
			buildPhases = (
				RESOURCES_PHASE /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = CleanME;
			productName = CleanME;
			productReference = APP_PRODUCT /* CleanME.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		PROJECT_OBJECT /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					APP_TARGET = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "CleanME" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = MAIN_GROUP;
			productRefGroup = PRODUCTS_GROUP /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				APP_TARGET /* CleanME */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		RESOURCES_PHASE /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				ASSETS_BUILD /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		DEBUG_CONFIG /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		RELEASE_CONFIG /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
			};
			name = Release;
		};
		APP_DEBUG_CONFIG /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES;
				CODE_SIGN_ENTITLEMENTS = "";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = CleanME;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.utilities";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dxbmark.cleanme;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		APP_RELEASE_CONFIG /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES;
				CODE_SIGN_ENTITLEMENTS = "";
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_HARDENED_RUNTIME = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = Info.plist;
				INFOPLIST_KEY_CFBundleDisplayName = CleanME;
				INFOPLIST_KEY_LSApplicationCategoryType = "public.app-category.utilities";
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				INFOPLIST_KEY_NSPrincipalClass = NSApplication;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.dxbmark.cleanme;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		PROJECT_CONFIG_LIST /* Build configuration list for PBXProject "CleanME" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				DEBUG_CONFIG /* Debug */,
				RELEASE_CONFIG /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		APP_CONFIG_LIST /* Build configuration list for PBXNativeTarget "CleanME" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				APP_DEBUG_CONFIG /* Debug */,
				APP_RELEASE_CONFIG /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = PROJECT_OBJECT /* Project object */;
}
EOF

echo "✅ Xcode project created!"
echo ""
echo "📝 Important settings configured:"
echo "   ✅ ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon"
echo "   ✅ ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES"
echo "   ✅ Dark Mode icon support enabled"
echo ""
echo "🚀 Next steps:"
echo "   1. open CleanME.xcodeproj"
echo "   2. Build (⌘B)"
echo "   3. Archive (Product → Archive)"
echo ""
