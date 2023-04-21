using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TrailRenderer))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed = 200.0f;
    [SerializeField] private float boostFactor = 4.0f;
    [SerializeField] private float power = 2.0f;
    [SerializeField] private TerrainGenerator generatedTerrain;
    [SerializeField] private float trailDecay = 5.0f;

    
    private float modifiedSpeed;
    private Vector3 movementDirection; 
    private TrailRenderer trail;

    void Awake()
    {
        transform.position = new Vector3(generatedTerrain.width/2, generatedTerrain.height/2, transform.position.z);
        trail = this.GetComponent<TrailRenderer>();

        if(generatedTerrain == null)
        {
            Debug.Log("You need pass a TrarrainGenerator component to the player.");
            throw new MissingComponentException();
        }
    }

    public float GetCurrentSpeed()
    {
        return modifiedSpeed;
    }

    public Vector3 GetMovementDirection()
    {
        return movementDirection;
    }

    void Update()
    {
        bool fire1Down = Input.GetButtonDown("Fire1");
        bool fire1Pressed = Input.GetButton("Fire1");
        bool fire1Up = Input.GetButtonUp("Fire1");

        bool fire2Down = Input.GetButtonDown("Fire2");
        bool fire2Pressed = Input.GetButton("Fire2");
        bool fire2Up = Input.GetButtonUp("Fire2");

        if(fire1Pressed)
        {
            generatedTerrain.ChangeTerrainHeight(gameObject.transform.position, power);
        }

        if(fire2Pressed)
        {
            generatedTerrain.ChangeTerrainHeight(gameObject.transform.position, -power);
        }

        if( (fire1Down && !fire2Pressed) || (fire2Down && !fire1Pressed)) 
        {
            FindObjectOfType<SoundManager>().PlaySoundEffect("Beam");
        }

        if( (fire1Up && !fire2Pressed) || (fire2Up && !fire1Pressed))
        {
            FindObjectOfType<SoundManager>().StopSoundEffect("Beam");
        }

        modifiedSpeed = speed;

        if (Input.GetButton("Jump"))
        {
            modifiedSpeed *= boostFactor;
            trail.widthMultiplier = boostFactor;

            if(Input.GetButtonDown("Jump"))
            {
                FindObjectOfType<SoundManager>().PlaySoundEffect("SonicBoom");
            }
        }
        else
        {
            if(trail.widthMultiplier >= 1.0f) {
                trail.widthMultiplier -= Time.deltaTime * trailDecay;
            }
        }

        movementDirection = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0.0f);
        gameObject.transform.Translate(movementDirection * Time.deltaTime * modifiedSpeed);
    }
}
