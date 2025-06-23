import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

// Main app bundle identifier - update this if the bundle ID changes
const MAIN_APP_BUNDLE_ID = 'edu.illinois.tianwei4.ikalendar2'

function getProjectFilePath(): string {
  const __filename = fileURLToPath(import.meta.url)
  const __dirname = path.dirname(__filename)
  // Navigate up 3 levels from docs/.vitepress/utils/ to project root
  return path.resolve(__dirname, '../../..', 'Ikalendar2.xcodeproj', 'project.pbxproj')
}

function extractBuildConfigSection(content: string): string {
  const match = content.match(/\/\* Begin XCBuildConfiguration section \*\/[\s\S]*?\/\* End XCBuildConfiguration section \*\//)
  if (!match) {
    throw new Error('XCBuildConfiguration section not found')
  }
  console.warn('XCBuildConfiguration section found')
  return match[0]
}

function findMainAppReleaseConfig(buildConfigSection: string): string {
  // Xcode project document creates multiple Release configurations:
  // - IkalendarKit framework
  // - IkalendarKitTests
  // - Main Ikalendar2 app  <==  This is what we want

  // Find all Release configurations that mention ikalendar2 in bundle identifier
  const releaseConfigs = buildConfigSection.match(/[A-F0-9]{24}\s+\/\* Release \*\/ = \{[\s\S]*?PRODUCT_BUNDLE_IDENTIFIER = [^;]*ikalendar2[^;]*;[\s\S]*?\};/gi) || []
  console.warn(`Release configurations found: ${releaseConfigs.length} match(es)`)

  // Find the configuration that matches our main app bundle ID exactly
  for (const config of releaseConfigs) {
    const bundleIdMatch = config.match(/PRODUCT_BUNDLE_IDENTIFIER = "?([^";]+)"?;/)
    if (bundleIdMatch) {
      const bundleId = bundleIdMatch[1]

      // Target the specific main app bundle ID
      if (bundleId === MAIN_APP_BUNDLE_ID) {
        console.warn('Found main app Release configuration with bundle ID:', bundleId)
        return config
      }
    }
  }

  throw new Error(`Main app Release configuration not found for bundle ID: ${MAIN_APP_BUNDLE_ID}`)
}

function extractVersionFromConfig(config: string): string {
  const versionMatch = config.match(/MARKETING_VERSION = "?([\d.]+)"?;/)
  if (!versionMatch) {
    throw new Error('MARKETING_VERSION not found in configuration')
  }
  console.warn('Marketing version found')
  return versionMatch[1]
}

export function extractIosAppVersion(): string {
  console.warn('--- Extracting iOS App Version ---')

  try {
    const projectPath = getProjectFilePath()

    if (!fs.existsSync(projectPath)) {
      throw new Error('project.pbxproj file not found')
    }
    console.warn('Project file read successfully')

    const content = fs.readFileSync(projectPath, 'utf-8')
    const buildConfigSection = extractBuildConfigSection(content)
    const mainAppConfig = findMainAppReleaseConfig(buildConfigSection)
    const version = extractVersionFromConfig(mainAppConfig)

    console.warn(`iOS App Version: ${version}`)
    console.warn('--- Extracting iOS App Version Complete ---')
    return version
  }
  catch (error) {
    console.warn('Error:', error.message)
    console.warn('--- Extracting iOS App Version Failed ---')
    return 'Unknown'
  }
}
