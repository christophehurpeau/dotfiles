#!/usr/bin/env node

/**
 * Fetches all package names associated with a given npm author using the npms.io API.
 * This API is more robust than web scraping and handles pagination.
 * @param {string} author - The npm username of the author.
 * @returns {Promise<string[]>} A promise that resolves to an array of unique package names.
 */
async function getPackagesByAuthor(author) {
  const packages = new Set(); // Use a Set to store unique package names
  const pageSize = 250; // npms.io default page size is 250, let's use this for pagination
  let from = 0;
  let total = 0;
  let fetchedCount = 0;

  console.log(`Fetching package list for "${author}" using npms.io API...`);

  // Loop to handle pagination until all packages are fetched
  do {
    // Construct the API URL to search for packages by maintainer, with pagination parameters
    const url = `https://api.npms.io/v2/search?q=maintainer:${author}&size=${pageSize}&from=${from}`;
    try {
      const response = await fetch(url);
      if (!response.ok) {
        // Throw an error if the API request was not successful
        throw new Error(
          `Failed to fetch packages from npms.io: ${response.status} ${response.statusText}`
        );
      }
      const data = await response.json();

      // Check if the response contains results
      if (data && data.results) {
        // Add each package name to the Set
        data.results.forEach((item) => {
          if (item.package && item.package.name) {
            packages.add(item.package.name);
          }
        });
        total = data.total; // Get the total number of packages for this author
        fetchedCount += data.results.length; // Increment count of fetched packages
        from += pageSize; // Move to the next page
      } else {
        console.warn("Unexpected response structure from npms.io API.");
        break; // Exit loop if the response structure is not as expected
      }
    } catch (error) {
      console.error(
        `Error fetching packages from npms.io for "${author}": ${error.message}`
      );
      return []; // Return an empty array on a critical error
    }
  } while (fetchedCount < total); // Continue looping as long as there are more packages to fetch

  const uniquePackageNames = [...packages]; // Convert the Set back to an array
  console.log(
    `Found ${uniquePackageNames.length} unique packages for "${author}".`
  );
  return uniquePackageNames;
}

/**
 * Fetches the last month's download count for a given npm package using the npm downloads API.
 * This function remains the same as it already uses an official API.
 * @param {string} packageName - The name of the npm package.
 * @returns {Promise<{ packageName: string, downloads: number }>} A promise that resolves to an object
 * containing the package name and its download count.
 */
async function getPackageDownloads(packageName) {
  const url = `https://api.npmjs.org/downloads/point/last-month/${packageName}`;
  try {
    const response = await fetch(url);
    if (!response.ok) {
      // If the package doesn't exist or downloads data is unavailable, return 0 downloads
      return { packageName, downloads: 0 };
    }
    const data = await response.json();
    // Ensure downloads is a number, default to 0 if null/undefined
    return { packageName, downloads: data.downloads || 0 };
  } catch (error) {
    console.error(
      `Error fetching downloads for "${packageName}": ${error.message}`
    );
    return { packageName, downloads: 0 };
  }
}

/**
 * Main function to get and display top packages by an author.
 * @param {string} author - The npm username of the author.
 * @param {number} [limit=50] - The number of top packages to display.
 */
async function main(author, limit = 50) {
  let allPackageNames = [];
  try {
    allPackageNames = await getPackagesByAuthor(author);
    if (allPackageNames.length === 0) {
      console.log(`No packages found for author "${author}". Exiting.`);
      return;
    }
  } catch (error) {
    console.error(
      `Application error during package list retrieval: ${error.message}`
    );
    return;
  }

  const packageDownloads = [];
  const concurrencyLimit = 10; // Limit concurrent requests to avoid hitting API rate limits
  let inFlightRequests = 0;
  let packageIndex = 0;

  console.log(
    `Fetching download counts for ${allPackageNames.length} packages (this might take a moment)...`
  );

  // Implement a simple concurrency queue for fetching downloads
  await new Promise((resolve) => {
    const processNext = async () => {
      // If all packages have been processed and all in-flight requests are complete, resolve the promise
      if (packageIndex >= allPackageNames.length && inFlightRequests === 0) {
        resolve();
        return;
      }

      // While there's capacity in the concurrency limit and more packages to process
      while (
        inFlightRequests < concurrencyLimit &&
        packageIndex < allPackageNames.length
      ) {
        const pkgName = allPackageNames[packageIndex++];
        inFlightRequests++;

        getPackageDownloads(pkgName)
          .then((data) => {
            packageDownloads.push(data);
          })
          .catch((err) => {
            console.error(
              `Failed to fetch downloads for ${pkgName}: ${err.message}`
            );
            // Still push an entry to ensure all packages are accounted for, even if downloads failed
            packageDownloads.push({ packageName: pkgName, downloads: 0 });
          })
          .finally(() => {
            inFlightRequests--;
            // Add a small delay between requests to be polite to the npm API
            // This helps prevent hitting rate limits and ensures a smooth execution
            setTimeout(processNext, 100);
          });
      }
    };
    // Start processing by trying to fill the concurrency queue
    processNext();
  });

  // Filter out packages with 0 downloads if they were due to errors/not found, but keep explicit 0s
  const filteredPackages = packageDownloads.filter((pkg) => pkg.downloads >= 0);

  // Sort packages by downloads in descending order
  filteredPackages.sort((a, b) => b.downloads - a.downloads);

  console.log(
    `\n--- Top ${Math.min(
      limit,
      filteredPackages.length
    )} NPM packages by "${author}" (Last Month Downloads) ---`
  );
  filteredPackages.slice(0, limit).forEach((pkg, i) => {
    console.log(
      `${i + 1}. ${
        pkg.packageName
      }: ${pkg.downloads.toLocaleString()} downloads`
    );
  });

  console.log(
    "------------------------------------------------------------------"
  );
}

// --- How to Run the Script ---
// Call the main function with the author's npm username and the desired limit.
// For "churpeau" and top 50:
main("churpeau", 50);

// You can change 'churpeau' to any other npm username
// and 50 to any other number to get a different top list.
// Example for another author and top 10:
// main('sindresorhus', 10);
