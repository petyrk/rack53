# Is this allowed?

This is my reading, not legal advice. I'm a network engineer, not a lawyer.

## US copyright law (DMCA Section 1201)

Since 2018, the Copyright Office's Section 1201 rulemaking has included an exemption for jailbreaking voice assistant devices such as the Amazon Echo. It was renewed in the rule that took effect on October 28, 2024.

The exemption covers circumventing protections on **your own device** so it can run or remove software. It does not cover trafficking in circumvention tools. That's why this repo links to amonet instead of hosting it.

- [EFF: DMCA exemption for jailbreaking Echo devices (2018)](https://www.eff.org/press/releases/eff-wins-dmca-exemption-petitions-tinkering-echos-and-repairing-appliances-new)
- [Finnegan: 2024 Section 1201 final rule](https://www.finnegan.com/en/insights/ip-updates/final-rule-issued-in-the-us-copyright-offices-ninth-triennial-section-1201-proceeding.html)

## Amazon's terms

Amazon's Conditions of Use forbid reverse engineering, tampering with, or bypassing security on Amazon Software. Some Amazon device licenses also say you won't encourage or assist others to modify the device. These are contract terms between you and Amazon. Expect a void warranty and no support for a flashed device.

## How this repo handles it

- Flash only devices you own. Remove each one from your Amazon account (Alexa app > Devices > Deregister) before you start.
- The repo holds documentation, terminal output and scripts that call upstream tools. It hosts no amonet code, no LineageOS images and no Amazon firmware.
- The kiosk image can run Amazon's own wake word engine if you supply its files. Those are Amazon's code and models. Don't commit them here.

Outside the US, check your own country's rules on device circumvention.
