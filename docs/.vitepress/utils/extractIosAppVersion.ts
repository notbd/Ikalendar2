import fs from 'node:fs'
import path from 'node:path'

function findMatches(content: string, regex: RegExp, description: string): string[] {
  const matches = content.matchAll(new RegExp(regex, 'g'))
  const results = Array.from(matches).map(match => match[0])
  if (results.length === 0) {
    throw new Error(`${description} not found`)
  }
  console.warn(`${description} found: ${results.length} match(es)`)
  return results
}

function getProjectFilePath(): string {
  let currentDir = __dirname
  for (let i = 0; i < 3; i++) {
    currentDir = path.dirname(currentDir)
  }
  return path.join(currentDir, 'Ikalendar2.xcodeproj', 'project.pbxproj')
}

function readProjectFile(filePath: string): string {
  if (!fs.existsSync(filePath)) {
    throw new Error('project.pbxproj file not found')
  }
  console.warn('Project file read successfully')
  return fs.readFileSync(filePath, 'utf-8')
}

function extractBuildConfigSection(content: string): string {
  const regex = /\/\* Begin XCBuildConfiguration section \*\/[\s\S]*?\/\* End XCBuildConfiguration section \*\//
  return findMatches(content, regex, 'XCBuildConfiguration section')[0]
}

function extractReleaseConfigs(buildConfigSection: string): string[] {
  const regex = /[A-F0-9]{24}\s+\/\* Release \*\/ = \{[\s\S]*?\};/g
  return findMatches(buildConfigSection, regex, 'Release configurations')
}

function extractMarketingVersion(releaseConfigs: string[]): string {
  const regex = /MARKETING_VERSION = ([\d.]+);/
  for (const config of releaseConfigs) {
    const match = config.match(regex)
    if (match && match[1]) {
      console.warn('Marketing version found')
      return match[1]
    }
  }
  throw new Error('Version number not found in Release configurations')
}

export function extractIosAppVersion(): string {
  console.warn('--- Extracting iOS App Version ---')
  try {
    const filePath = getProjectFilePath()
    const content = readProjectFile(filePath)
    const buildConfigSection = extractBuildConfigSection(content)
    const releaseConfigs = extractReleaseConfigs(buildConfigSection)
    const version = extractMarketingVersion(releaseConfigs)
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
