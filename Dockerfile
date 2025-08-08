import React, { useState } from 'react';

// Use lucide-react for icons
const FileIcon = ({ size = 20, color = "currentColor", ...props }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke={color}
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="M14.5 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V7.5L14.5 2z" />
    <polyline points="14 2 14 8 20 8" />
  </svg>
);

const JsonIcon = ({ size = 20, color = "currentColor", ...props }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke={color}
    strokeWidth="2"
    strokeLinecap="round"
    strokeLinejoin="round"
    {...props}
  >
    <path d="M16 11.5a2.5 2.5 0 0 1-5 0V9a1 1 0 0 0-1-1H6" />
    <path d="M12 2v2" />
    <path d="M15 2v2" />
    <path d="M18 2v2" />
    <path d="M21 2v2" />
    <path d="M3 2v2" />
    <path d="M6 2v2" />
    <path d="M9 2v2" />
    <path d="M12 11.5v2" />
    <path d="M12 13.5a2.5 2.5 0 0 0-5 0v2.5a1 1 0 0 1-1 1H3" />
    <path d="M12 13.5a2.5 2.5 0 0 1 5 0v2.5a1 1 0 0 0 1 1h2.5" />
    <path d="M12 18v2" />
  </svg>
);

const App = () => {
  const [activeFile, setActiveFile] = useState('Dockerfile');

  const DockerfileContent = `
# Use a base Ubuntu image
FROM ubuntu:22.04

# Set a non-interactive mode for commands
ENV DEBIAN_FRONTEND=noninteractive

# Update the system and install necessary packages
# 'curl' is for downloading sshx, 'gnupg' is for Docker's GPG key
RUN apt-get update && apt-get install -y \\
    curl \\
    gnupg \\
    lsb-release \\
    ca-certificates \\
    software-properties-common \\
    --no-install-recommends && \\
    rm -rf /var/lib/apt/lists/*

# Install sshx with full root privileges
# This command fetches the installation script and pipes it to sh
# The script will install the latest version of sshx
RUN curl -sS https://raw.githubusercontent.com/sshx/sshx/main/install.sh | sudo sh

# Install Docker inside the container
# This is a multi-step process to ensure a clean installation
RUN mkdir -p /etc/apt/keyrings && \\
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \\
    echo \\
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \\
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \\
    apt-get update && \\
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set the working directory
WORKDIR /

# Expose port 80 to allow incoming connections
# Note: Railway will handle port mapping automatically
EXPOSE 80

# This is the command that will be executed when the container starts.
# It starts an sshx session, granting full root access.
# The logs will contain the URL to connect to the session.
CMD ["sshx", "--shell=/bin/bash"]
  `;

  const railwayJsonContent = `
{
  "build": {
    "dockerfile": "Dockerfile"
  },
  "start": "sshx --shell=/bin/bash"
}
  `;

  return (
    <div className="flex flex-col h-full bg-gray-900 text-gray-200 font-sans rounded-xl overflow-hidden shadow-2xl">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between p-4 bg-gray-800 border-b border-gray-700">
        <h2 className="text-xl sm:text-2xl font-bold mb-2 sm:mb-0 text-white">Railway SSHX Setup</h2>
        <div className="flex space-x-2">
          <button
            onClick={() => setActiveFile('Dockerfile')}
            className={\`flex items-center px-4 py-2 rounded-lg transition-colors duration-200 \${
              activeFile === 'Dockerfile'
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }\`}
          >
            <FileIcon className="mr-2" /> Dockerfile
          </button>
          <button
            onClick={() => setActiveFile('railway.json')}
            className={\`flex items-center px-4 py-2 rounded-lg transition-colors duration-200 \${
              activeFile === 'railway.json'
                ? 'bg-blue-600 text-white shadow-lg'
                : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
            }\`}
          >
            <JsonIcon className="mr-2" /> railway.json
          </button>
        </div>
      </div>

      <div className="p-4 sm:p-6 overflow-auto">
        <pre className="text-sm sm:text-base font-mono p-4 rounded-lg bg-gray-800 text-gray-300 whitespace-pre-wrap overflow-x-auto">
          <code className="language-bash">
            {activeFile === 'Dockerfile' ? DockerfileContent.trim() : railwayJsonContent.trim()}
          </code>
        </pre>
      </div>

      <style jsx global>{`
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;700&display=swap');
        body {
          font-family: 'Inter', sans-serif;
        }
      `}</style>
    </div>
  );
};

export default App;
