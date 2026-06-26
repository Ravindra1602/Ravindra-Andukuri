// Mobile Menu Toggle
const hamburger = document.querySelector('.hamburger');
const navMenu = document.querySelector('.nav-menu');

if (hamburger) {
    hamburger.addEventListener('click', () => {
        navMenu.style.display = navMenu.style.display === 'flex' ? 'none' : 'flex';
        hamburger.classList.toggle('active');
    });
}

// Smooth Scrolling for Navigation Links
const navLinks = document.querySelectorAll('.nav-link');
navLinks.forEach(link => {
    link.addEventListener('click', (e) => {
        navLinks.forEach(l => l.classList.remove('active'));
        link.classList.add('active');
        if (navMenu.style.display === 'flex') {
            navMenu.style.display = 'none';
            hamburger.classList.remove('active');
        }
    });
});

// Form Submission
const contactForm = document.getElementById('contactForm');
if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const name = contactForm.querySelector('input[type="text"]').value;
        const email = contactForm.querySelector('input[type="email"]').value;
        const subject = contactForm.querySelector('input[type="text"]:nth-of-type(2)').value;
        const message = contactForm.querySelector('textarea').value;
        
        // Validate form
        if (name && email && message) {
            // Here you can add your form submission logic
            // For now, just show success message
            alert('Thank you for your message! I will get back to you soon.');
            contactForm.reset();
        } else {
            alert('Please fill in all required fields.');
        }
    });
}

// Add scroll effect to navbar
window.addEventListener('scroll', () => {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.15)';
    } else {
        navbar.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
    }
});

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe elements for animation
const elementsToObserve = document.querySelectorAll('.skill-category, .project-card, .timeline-item, .publication-item');
elementsToObserve.forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
    observer.observe(el);
});

// Navbar active link highlight based on scroll position
window.addEventListener('scroll', () => {
    let current = '';
    const sections = document.querySelectorAll('section');
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        if (scrollY >= sectionTop - 200) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href').slice(1) === current) {
            link.classList.add('active');
        }
    });
});

// Add typing effect to hero title
const heroTitle = document.querySelector('.hero-title');
if (heroTitle) {
    const text = heroTitle.textContent;
    heroTitle.textContent = '';
    let index = 0;
    
    const typeWriter = () => {
        if (index < text.length) {
            heroTitle.textContent += text.charAt(index);
            index++;
            setTimeout(typeWriter, 50);
        }
    };
    
    // Start typing animation when element is in view
    const typeWriterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting && index === 0) {
                typeWriter();
                typeWriterObserver.unobserve(entry.target);
            }
        });
    });
    
    typeWriterObserver.observe(heroTitle);
}

// Counter animation for stats
const statElements = document.querySelectorAll('.stat h3');
const startCounterAnimation = (element) => {
    const target = parseInt(element.textContent);
    const increment = target / 30;
    let current = 0;
    
    const counter = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = target + '+';
            clearInterval(counter);
        } else {
            element.textContent = Math.floor(current) + '+';
        }
    }, 30);
};

const statsObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            startCounterAnimation(entry.target);
            statsObserver.unobserve(entry.target);
        }
    });
}, { threshold: 0.5 });

statElements.forEach(element => statsObserver.observe(element));

// Console message
console.log('%c👋 Welcome to Ravindra\'s Portfolio!', 'font-size: 20px; color: #667eea; font-weight: bold;');
console.log('%c🚀 Full Stack Developer | ML Researcher | Innovation Enthusiast', 'font-size: 14px; color: #764ba2;');
console.log('%c📧 Let\'s connect!', 'font-size: 14px; color: #f093fb;');