#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

# Get the IMDSv2 token
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Background the curl requests
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4 &> /tmp/local_ipv4 &
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone &> /tmp/az &
curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ &> /tmp/macid &
wait

macid=$(cat /tmp/macid)
local_ipv4=$(cat /tmp/local_ipv4)
az=$(cat /tmp/az)
vpc=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${macid}/vpc-id)
HOST_NAME=$(hostname -f)

# The shell will replace the variables like $local_ipv4 with the values we got from curl.
# Using a "heredoc" (here document) - a cleaner way to write multi-line text
# "cat << EOF" means "output everything until you see 'EOF' on its own line"
# This is easier to read than using echo with quotes, especially for HTML
# '/var/www/html/index.html' is the location of the html script on the new server
cat <<EOF > /var/www/html/index.html
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3rd EC2 instance</title>
    <link rel="stylesheet" href="style.css?v=2.14.CC">
</head>
<body>
    <div class="header-shape">
        <h1>AWS Instance 3 Details</h1>
        <h2>All done in Terraform with Blood, Sweat and Tears.</h2>
        <p>I, Jaune Alcide, thank Suge WAF and My Senpais, For Teaching Me About the Cloud. One Step Closer To Escaping Keisha!</p>
        <p><strong>With This Class, I Will Net >\$500,000 Per Year!</strong></p>
    </div>

    <div class="hexagon-gallery">
        <div class="hex-row">
            <div class="hexagon-item" data-src="https://images.squarespace-cdn.com/content/v1/59b6e91c9f7456a2afa651ea/1705512854437-C44OYKAYH75IKSMZST2Q/us3.jpg?">
                <div class="hexagon">
                    <img src="https://images.squarespace-cdn.com/content/v1/59b6e91c9f7456a2afa651ea/1705512854437-C44OYKAYH75IKSMZST2Q/us3.jpg?" alt="Lush green forest">
                    <div class="hex-text"><span>Future Home with Lake</span></div>
                </div>
            </div>
            <div class="hexagon-item" data-src="https://images.ctfassets.net/jvp71l3ed0ev/1enrLXaefsCtsz58tGGOz6/d36720cd525c7582c0b3e90b847eb026/11.jpg">
                <div class="hexagon">
                    <img src="https://images.ctfassets.net/jvp71l3ed0ev/1enrLXaefsCtsz58tGGOz6/d36720cd525c7582c0b3e90b847eb026/11.jpg" alt="River in a mountain valley">
                    <div class="hex-text"><span>Future Home with Onsen</span></div>
                </div>
            </div>
        </div>
        <div class="hex-row">
            <div class="hexagon-item" data-src="https://i.redd.it/s9qqpjka4lk51.jpg">
                <div class="hexagon">
                    <img src="https://i.redd.it/s9qqpjka4lk51.jpg" alt="Misty forest path">
                    <div class="hex-text"><span>Simple Smile</span></div>
                </div>
            </div>
            <div class="hexagon-item" data-src="https://pbs.twimg.com/media/FMUNqatXIAcLylN.jpg:large">
                <div class="hexagon">
                    <img src="https://pbs.twimg.com/media/FMUNqatXIAcLylN.jpg:large" alt="Sun setting over a grassy field">
                    <div class="hex-text"><span>The Blacker the Berry</span></div>
                </div>
            </div>
            <div class="hexagon-item" data-src="https://www.stlbrideandgroom.com/wp-content/uploads/2023/10/NaomiDate17-768x960.jpg">
                <div class="hexagon">
                    <img src="https://www.stlbrideandgroom.com/wp-content/uploads/2023/10/NaomiDate17-768x960.jpg" alt="Sun rays through a large tree">
                    <div class="hex-text"><span>That Gaze</span></div>
                </div>
            </div>
        </div>
    </div>

    <div class="details-box">
        <div class="instance-info">
            <p><b>Instance Name:</b> ${HOST_NAME}</p>
            <p><b>Instance Private Ip Address: </b> ${local_ipv4}</p>
            <p><b>Availability Zone: </b> ${az}</p>
            <p><b>Virtual Private Cloud (VPC):</b> ${vpc}</p>
        </div>

        <div class="button-container">
            <a href="https://s.yimg.com/ny/api/res/1.2/h4wYAD4g999h1LHvNkm0DA--/YXBwaWQ9aGlnaGxhbmRlcjt3PTY0MDtoPTgwMA--/https://media.zenfs.com/en/aol_bored_panda_979/ad897869a3d3d3b86da214f079e5b89b" target="_blank" class="repo-button">
                Don't want to read? Great, have this!
            </a>
            <a href="https://github.com/Jae1-alt/ec2_bastion-/tree/main" target="_blank" class="repo-button">
                This project's GitHub Repo.
            </a>
        </div>
    </div>

    <div id="imageModal" class="modal">
        <span class="close-button">&times;</span>
        <img class="modal-content" id="modalImage">
    </div>

    <script>
        // Get the elements we need to work with
        const modal = document.getElementById('imageModal');
        const modalImg = document.getElementById('modalImage');
        const closeBtn = document.querySelector('.close-button');
        const hexagonItems = document.querySelectorAll('.hexagon-item');

        // Loop through all hexagons and add a click event to each
        hexagonItems.forEach(item => {
            item.addEventListener('click', () => {
                modal.style.display = 'flex'; // Show the modal (using flex to center content)
                modalImg.src = item.dataset.src; // Set the image source from the data-src attribute
            });
        });

        // Function to close the modal
        function closeModal() {
            modal.style.display = 'none';
        }

        // Add click events to close the modal
        closeBtn.addEventListener('click', closeModal);
        modal.addEventListener('click', (e) => {
            // Close the modal if the user clicks on the dark overlay (but not the image itself)
            if (e.target === modal) {
                closeModal();
            }
        });
    </script>
</body>
</html>
EOF

#Create the CSS file using another Heredoc
cat <<EOF > /var/www/html/style.css
body {
  font-family: sans-serif;
  background-image: url('https://images.unsplash.com/photo-1528164344705-47542687000d?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8amFwYW4lMjB3YWxscGFwZXJ8ZW58MHx8MHx8fDA%3D&fm=jpg&q=60&w=3000');
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center center;
  background-attachment: fixed;
  color: white;
  margin: 0;
  padding: 2vh 20px;
  box-sizing: border-box;
  text-align: center;
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* --- Header Shape --- */
.header-shape {
    padding: 40px 60px;
    margin: 0 auto 40px auto;
    width: 98%;
    max-width: 1400px;
    background-color: rgba(40, 40, 40, 0.8);
    color: white;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.5);
    /* CHANGED: Border color is now blue */
    border: 3px solid #3498db;
    border-radius: 60px 60px 15px 15px;
    box-sizing: border-box;
}

h1, h2 {
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.7);
}

/* --- Hexagon Gallery --- */
.hexagon-gallery {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  margin-bottom: 40px;
  gap: 5px;
}
.hex-row {
  display: flex;
  justify-content: center;
  gap: 20px;
}
.hex-row:nth-child(2) { margin-top: -52px; }
.hexagon-item {
  display: block;
  cursor: pointer;
  /* CHANGED: Swapped the red glow for a blue one */
  filter: drop-shadow(0 0 10px rgba(52, 152, 219, 0.5));
  transition: filter 0.3s ease;
}
.hexagon {
  position: relative;
  width: 180px;
  height: 208px;
  background-color: #333;
  overflow: hidden;
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
  transition: transform 0.3s ease-in-out;
}
.hexagon img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: filter 0.3s ease;
}
.hex-text {
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  font-weight: normal;
  font-size: 1.1em;
  padding: 10px;
  text-align: center;
  opacity: 0;
  transition: opacity 0.3s ease;
}
.hexagon-item:hover .hex-text { opacity: 1; }
.hexagon-item:hover .hexagon img { filter: brightness(0.6); }
.hexagon-item:hover .hexagon { transform: scale(1.1); }
.hexagon-item:hover {
    /* CHANGED: Made the hover glow a stronger blue */
    filter: drop-shadow(0 0 15px rgba(52, 152, 219, 0.8));
}

/* --- Bottom Details Box --- */
.details-box {
    width: 98%;
    max-width: 1400px;
    margin: 40px auto 20px auto;
    padding: 25px;
    background-color: rgba(40, 40, 40, 0.8);
    color: white;
    /* CHANGED: Border color is now blue */
    border: 3px solid #3498db;
    border-radius: 15px;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
}
.instance-info {
  display: grid;
  grid-template-columns: 1fr 1fr;
  grid-template-rows: auto auto;
  gap: 15px 25px;
  margin-bottom: 30px;
  text-align: left;
  max-width: 800px;
  margin-left: auto;
  margin-right: auto;
}
.button-container {
    margin-top: 20px;
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 20px;
}

/* CHANGED: Button theme is now white and blue */
.repo-button {
  display: inline-block;
  padding: 15px 30px;
  font-size: 1.1em;
  background-image: linear-gradient(45deg, #ffffff 0%, #aed6f1 100%);
  color: #2980b9; /* Dark blue text for contrast */
  text-decoration: none;
  font-weight: bold;
  border-radius: 50px;
  border: 2px solid #2980b9; /* Solid dark blue border */
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  text-shadow: none;
  transition: all 0.3s ease;
}
.repo-button:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(52, 152, 219, 0.4); /* Blue shadow on hover */
}

/* CORRECTED: CSS for the image modal */
.modal {
  display: none;
  position: fixed;
  z-index: 1000;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.85);
  align-items: center;
  justify-content: center;
}

.modal-content {
  margin: auto;
  display: block;
  max-width: 85%;
  max-height: 85%;
  border-radius: 5px;
}

.close-button {
  position: absolute;
  top: 20px;
  right: 35px;
  color: #f1f1f1;
  font-size: 40px;
  font-weight: bold;
  transition: 0.3s;
  cursor: pointer;
}

.close-button:hover,
.close-button:focus {
  color: #bbb;
  text-decoration: none;
}
EOF

# Clean up the temp files
rm -f /tmp/local_ipv4 /tmp/az /tmp/macid